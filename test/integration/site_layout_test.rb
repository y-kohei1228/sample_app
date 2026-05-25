require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "layout links when not logged in" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count:  2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", users_path, count: 0 # # ログインしてないのでUsersは表示されない
    get contact_path
    assert_select "title", full_title("Contact")

    get signup_path
    assert_select "title", full_title("Sign up")
  end

  test "layout links when logged in" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count:  2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", login_path, count: 0 # ログインしているのでLoginは表示されない
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path, count:0  # ログインしているのでsignupは表示されない
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", users_path # ログインしているのでUsersは表示される
    assert_select "a[href=?]", edit_user_path(@user)
  end

  test "home page stats" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', following_user_path(@user), text: /#{@user.following.count}/
    assert_select 'a[href=?]', followers_user_path(@user), text: /#{@user.followers.count}/
  end

end
