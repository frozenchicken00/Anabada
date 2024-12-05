require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "user can sign in" do
    user = FactoryBot.create :user, email: "test@test.com", password: "password"

    visit root_path

    click_on "Sign In"

    fill_in "email", with: "test@test.com"
    fill_in "password", with: "password"
    click_button "Sign in"

    assert_text "Signed in successfully"

    assert_equal root_path, page.current_path
    assert_not page.has_content?("Sign In")
  end

  test "user can't login" do
    user = FactoryBot.create :user, email: "test@test.com", password: "password"

    visit sign_in_path

    fill_in "email", with: "test@test.com"
    fill_in "password", with: "wrongpassword"
    click_button "Sign in"

    assert_not page.has_content?("Sign Out")
  end

  test "user can sign out" do
    login_user username: "test"

    visit root_path

    click_on "Sign Out"
    assert_text "Signed out successfully!"
    assert_not page.has_content?("Sign Out")
  end
end
