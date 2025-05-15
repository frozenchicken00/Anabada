# Searchkick.client = Elasticsearch::Client.new(
#   url: ENV.fetch("ELASTICSEARCH_URL", "http://elasticsearch:9200"),
#   transport_options: {
#     request: { timeout: 5 }
#   }
# )
if Rails.env.production?
  # Disable searchkick in production
  module Searchkick
    def self.search(*args)
      model = args.shift
      model.all
    end
  end

  # Override Product model search method
  if defined?(Product)
    class Product < ApplicationRecord
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
