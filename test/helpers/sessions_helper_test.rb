require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  helper SessionsHelper

  test 'current_user returns user when session exists' do
    user = users(:michael)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
    assert_equal user, current_user
  end

  test 'remember sets remember_digest' do
    @user.save!
    @user.remember
    assert_not @user.remember_digest.nil?
    assert @user.authenticated?(:remember, @user.remember_token)
  end

end
