class AddUserToComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :comments, :user, null: true, foreign_key: true
  end
end
