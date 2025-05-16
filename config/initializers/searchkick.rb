if defined?(Searchkick) && Rails.env.production?
  # Completely disable Searchkick in production

  # 1. Disable client connection
  Searchkick.client = nil

  # 2. Remove callbacks to prevent indexing on save/create
  module Searchkick
    module Model
      def searchkick(options = {})
        # Do nothing in production
      end
    end
  end

  # 3. Override search methods
  Searchkick.class_eval do
    def self.search(term = nil, options = {}, &block)
      if options[:models] && options[:models].first
        options[:models].first.all
      else
        []
      end
    end
  end

  # 4. Make sure callbacks don't run
  module SearchkickCallbacksDisabler
    def reindex(method_name = nil, options = {})
      # Do nothing
    end
  end
  Searchkick::Callbacks.prepend SearchkickCallbacksDisabler

  # 5. Reopen the Product class to add a direct search method
  if defined?(Product)
    Product.class_eval do
      # Override the search method
      def self.search(query, options = {})
        if query.present?
          where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
        else
          all
        end
      end
    end
  end
else
  # Regular configuration for non-production environments
  if defined?(Searchkick)
    Searchkick.client = Elasticsearch::Client.new(
      url: ENV.fetch("ELASTICSEARCH_URL", "http://elasticsearch:9200"),
      transport_options: {
        request: { timeout: 5 }
      }
    )
  end
end
