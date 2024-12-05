require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "valid product" do
    user = create(:user)
    category = create(:category)
    product = build(:product, user: user, category: category)
    assert product.valid?
  end

  test "invalid without name" do
    product = build(:product, name: nil)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "invalid without description" do
    product = build(:product, description: nil)
    assert_not product.valid?
    assert_includes product.errors[:description], "can't be blank"
  end

  test "invalid without price" do
    product = build(:product, price: nil)
    assert_not product.valid?
    assert_includes product.errors[:price], "is not a number"
  end

  test "price must be greater than or equal to 0" do
    product = build(:product, price: -10)
    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than or equal to 0"
  end

  test "belongs to a user" do
    product = build(:product)
    assert_not_nil product.user
  end

  test "belongs to a category" do
    product = build(:product)
    assert_not_nil product.category
  end
end
