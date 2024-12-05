class AddCategoryToProducts < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :category, null: true, foreign_key: true
  end
end
