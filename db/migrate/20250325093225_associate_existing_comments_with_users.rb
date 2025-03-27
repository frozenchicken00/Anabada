class AssociateExistingCommentsWithUsers < ActiveRecord::Migration[7.2]
  def up
    # For each comment without a user, associate it with the product's user
    execute <<-SQL
      UPDATE comments#{' '}
      SET user_id = products.user_id#{' '}
      FROM products#{' '}
      WHERE comments.product_id = products.id#{' '}
      AND comments.user_id IS NULL
    SQL
  end

  def down
    # This can't be safely undone, so we do nothing
  end
end
