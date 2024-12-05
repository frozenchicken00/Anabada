class Product < ApplicationRecord
  searchkick word_start: [ :name, :description ], searchable: [ :name, :description ]

  belongs_to :user
  belongs_to :category

  has_many_attached :pictures
  has_many :comments, dependent: :destroy

  validates :name, :description, :category_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def search_data
    {
      name: name,
      description: description,
      category_name: category&.name,
      price: price
    }
  end
end
