require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "", email: "foo@invalid", password: "foo", password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select "div.alert", text: 'The form contains 4 errors.'
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name, email: email, password: "", password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "Friendly forwarding should work only on the first login" do
    # 1. 編集ページを開き（ログインしていない）、リダイレクトされる
    get edit_user_path(@user)
    assert_redirected_to login_url

    # 2. ログインすると、編集ページにリダイレクトされる
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    # 3. forwarding_urlがnil（消去されている）かチェック
    assert_nil session[:forwarding_url]

    # 4. ログアウトして再度ログインすると、今度はデフォルトのページへ
    delete logout_path
    log_in_as(@user)
    assert_redirected_to @user  # デフォルトでプロフィールページなど
  end
end
