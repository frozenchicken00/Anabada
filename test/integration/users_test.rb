require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  test "user sign up" do
    visit root_path
    click_on "Sign Up"

    within "#new_profile_form" do
      fill_in "username", with: "chicken12"
      fill_in "email", with: "chicken12@test12.com"
      fill_in "password", with: "qwer1234"
      fill_in "password confirmation", with: "qwer1234"
    end

    click_button "Sign up"

    assert_equal root_path, page.current_path
    assert_text "Sign up successful!"

    assert_not page.has_content?("Sign in")
  end

  # test "user cannot sign up" do
  #   visit sign_up_path

  #   within "#new_profile_form" do
  #     fill_in "username", with: "chicken12"
  #     fill_in "email", with: "chicken12@test12.com"
  #     fill_in "password", with: "qwer1234"
  #     fill_in "password confirmation", with: "qwe1234"
  #   end

  #   click_button "Sign up"
  #   assert_equal sign_up_path, page.current_path
  # end

  test "user can edit their profile" do
    user = FactoryBot.create(:user)
    signin_user(user)

    visit user_path(user)
    assert_text user.username
    assert_text user.email

    click_on "Edit Profile"
    assert_current_path edit_user_path(user)

    within "#edit_profile_form" do
      fill_in "username", with: "updated_username"
      fill_in "email", with: "updated@example.com"
      fill_in "Current password", with: "password"
      click_button "Update Profile"
    end

    assert_text "Profile was successfully updated"
    assert_text "updated_username"
    assert_text "updated@example.com"

    user.reload
    assert_equal "updated_username", user.username
    assert_equal "updated@example.com", user.email

    click_on "Edit Profile"
    within "#edit_profile_form" do
      fill_in "Current password", with: "password"
      fill_in "New Password", with: "newpassword123"
      fill_in "Confirm New Password", with: "newpassword123"
      click_button "Update Profile"
    end

    assert_text "Profile was successfully updated."
  end

  test "user cannot edit other users' profiles" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)

    signin_user(user1)

    visit edit_user_path(user2)

    assert_current_path root_path
    assert_text "You are not authorized to perform this action."

    visit user_path(user2)
    assert_not page.has_content?("Edit Profile")
  end

  test "user can delete their account with password" do
    user = FactoryBot.create(:user)
    signin_user(user)

    visit edit_user_path(user)

    within "#delete_account_form" do
      fill_in "delete_confirmation_password", with: "password"

      assert_difference("User.count", -1) do
        click_button "Delete my account"
      end
    end

    assert_current_path root_path
    assert_text "Your account has been deleted"
  end

  test "user cannot delete other users' accounts" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)

    signin_user(user1)

    page.driver.submit :delete, user_path(user2), {}

    assert_current_path root_path
    assert_text "You are not authorized to perform this action"
    assert_not_nil User.find_by(id: user2.id)
  end
end
