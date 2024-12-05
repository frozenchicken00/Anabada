json.extract! product, :id, :name, :description, :posted_date, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
