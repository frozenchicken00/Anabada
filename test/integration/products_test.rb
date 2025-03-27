require "test_helper"

class ProductsTest < ActionDispatch::IntegrationTest
  test "user must be logged in to create product" do
    category = FactoryBot.create :category

    visit new_product_path
    assert_equal sign_in_path, current_path

    user = login_user

    visit new_product_path
    assert_equal new_product_path, current_path

    fill_in "Name", with: "Test Product"
    fill_in "Description", with: "Test Description"
    fill_in "Price", with: "99.99"
    select category.name, from: "product[category_id]"

    click_button "Save Product"

    assert_equal user.id, Product.last.user_id
    assert_equal category.id, Product.last.category_id
  end

  test "non-logged in users can view products" do
    # user = FactoryBot.create :user
    product = FactoryBot.create :product

    visit products_path
    assert_text product.name

    visit product_path(product)
    assert_text product.name
    assert_text product.description

    assert page.has_no_link?("Edit"), "Expected no 'Edit' link, but one was found."
    assert page.has_no_button?("Delete"), "Expected no 'Delete' button, but one was found."
  end

  test "current user can edit and delete their own products" do
    user = FactoryBot.create(:user)
    category = FactoryBot.create(:category)

    signin_user(user)

    product = FactoryBot.create(:product, user: user, category: category)

    visit product_path(product)

    assert_text product.name
    assert_text product.description
    assert_text "$#{'%.2f' % product.price}"

    # Edit testing
    click_on "Edit"

    assert_current_path edit_product_path(product)

    fill_in "Name", with: "Updated Product Name"
    fill_in "Description", with: "Updated Description"
    fill_in "Price", with: "199.99"
    select category.name, from: "product[category_id]"

    click_button "Save Product"

    assert_text "Product was successfully updated."
    assert_text "Updated Product Name"
    assert_text "Updated Description"
    assert_text "$199.99"

    visit product_path(product)
    assert_text "Updated Product Name"
    assert_text "Updated Description"
    assert_text "$199.99"

    # Delete testing
    product_name = product.name

    assert_difference("Product.count", -1) do
      click_button "Delete"
    end

    assert_text "Product was successfully destroyed."
    assert_current_path products_path
    assert_no_text product_name
  end

  test "user can manage comments on products" do
    user = FactoryBot.create(:user)
    product = FactoryBot.create(:product)
    signin_user(user)

    # Leave a comment
    assert_difference("Comment.count", 1) do
      visit product_path(product)
      fill_in "Add comment...", with: "Test comment"
      click_button "Submit"
    end

    assert_text "Comment was successfully created"
    assert_text "Test comment"

    comment = Comment.last
    assert_equal "Test comment", comment.content
    assert_equal product.id, comment.product_id

    # Vote helpful
    within ".comments-list" do
      assert_equal 0, comment.helpful_vote
      click_on "Vote Helpful"
      assert_text "Helpful Votes: 1"
      comment.reload
      assert_equal 1, comment.helpful_vote
    end

    # Reply to comment
    assert_difference("Comment.count", 1) do
      click_on "Reply"
      fill_in "Write a reply...", with: "Test reply"
      click_button "Submit"
    end

    assert_text "Comment was successfully created."
    reply = Comment.last
    assert_equal "Test reply", reply.content
    assert_equal product.id, reply.product_id
    assert_equal comment.id, reply.parent_comment_id

    within ".replies-list" do
      assert_text "Test reply"
    end

    # Edit comment
    within ".comment-item" do
      first(:link, "Edit").click
    end

    fill_in "Content", with: "Updated comment"
    click_button "Submit"

    assert_text "Comment was successfully updated"
    assert_text "Comment: Updated comment"

    # Delete comment
    assert_difference("Comment.count", -2) do
      within ".comment-item" do
        first(:button, "Delete").click
      end
    end

    assert_text "Comment was successfully deleted."
    assert_no_text "Updated comment"
    assert_no_text "Test reply"
    comment.reload rescue assert_nil(Comment.find_by(id: comment.id))
    reply.reload rescue assert_nil(Comment.find_by(id: reply.id))
  end
end
