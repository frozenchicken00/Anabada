class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.datetime :posted_date
      t.decimal :price

      t.timestamps
    end
  end
end
