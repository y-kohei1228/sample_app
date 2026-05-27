require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'full title helper' do
    assert_equal 'Ruby on Rails Tutorial Sample App', full_title
    assert_equal 'Help | Ruby on Rails Tutorial Sample App', full_title('Help')
  end
end

class SessionsHelperTest < ActionView::TestCase
  helper SessionsHelper
  def setup
    @user = users(:michael)
    remember(@user)
  end

  test 'current_user returns right user when session is nil' do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test 'current_user returns nil when remember digest is wrong' do
    @user.update!(remember_digest: User.digest(User.new_token))
    assert_nil current_user
  end
end
