module AuthenticationMacros
  def login_user(user_properties = {})
    user = FactoryBot.create :user, user_properties
    visit sign_in_path
    fill_in "email", with: user.email
    fill_in "password", with: user.password

    click_button "Sign in"

    user
  end

  def signin_user(user = nil)
    user ||= FactoryBot.create(:user)

    visit sign_in_path
    fill_in "email", with: user.email
    fill_in "password", with: "password"

    click_button "Sign in"
    user
  end

  def reset_login
    reset_session!
  end
end
