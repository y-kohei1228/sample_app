require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
  
  test 'valid account activation' do
    user = users(:inactive)
    user.activation_token = User.new_token
    user.update!(activation_digest: User.digest(user.activation_token))
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    assert_redirected_to user
  end
end
