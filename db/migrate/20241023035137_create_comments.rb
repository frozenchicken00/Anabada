class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.text :content
      t.references :product, null: false, foreign_key: true
      t.integer :helpful_vote, default: 0
      t.references :parent_comment, foreign_key: { to_table: :comments }

      t.timestamps
    end
  end
end
