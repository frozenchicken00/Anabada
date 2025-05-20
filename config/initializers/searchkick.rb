# Only load if Searchkick is defined
if defined?(Searchkick)
  if Rails.env.production?
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

    # 4. Safely handle Callbacks module - DON'T access Searchkick::Callbacks directly
    begin
      if Searchkick.const_defined?(:Callbacks)
        module SearchkickCallbacksDisabler
          def reindex(method_name = nil, options = {})
            # Do nothing
          end
        end

        # Use safer approach with const_get instead of direct access
        callbacks_class = Searchkick.const_get(:Callbacks)
        callbacks_class.prepend SearchkickCallbacksDisabler
      end
    rescue => e
      # Log error but don't fail initialization
      Rails.logger.warn "Failed to disable Searchkick callbacks: #{e.message}"
    end

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
    Searchkick.client = Elasticsearch::Client.new(
      url: ENV.fetch("ELASTICSEARCH_URL", "http://elasticsearch:9200"),
      transport_options: {
        request: { timeout: 5 }
      }
    )
  end
end
