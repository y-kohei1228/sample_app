require 'rails_helper'

RSpec.describe 'Users', type: :request do
  fixtures :all

  let(:admin) { users(:michael) }
  let(:non_admin) { users(:archer) }

  it 'shows index to admin with pagination and delete links' do
    log_in_as(admin)
    get users_path

    expect(response).to have_http_status(:success)
    expect(response.body).to match(/class="pagination"/)
    expect(response.body).to match(%r{<a[^>]+(?:href="/users/\d+"[^>]*data-turbo-method="delete"|data-turbo-method="delete"[^>]*href="/users/\d+")})

    User.where(activated: true).paginate(page: 1).each do |user|
      expect(response.body).to include(user_path(user))
      expect(response.body).to include(user.name)
    end

    expect do
      delete user_path(non_admin)
    end.to change(User, :count).by(-1)

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(users_url)
  end

  it 'hides delete links for non-admin users' do
    log_in_as(non_admin)
    get users_path

    expect(response.body).not_to match(%r{<a[^>]+(?:href="/users/\d+"[^>]*data-turbo-method="delete"|data-turbo-method="delete"[^>]*href="/users/\d+")})
  end

  it 'renders signup page' do
    get signup_path
    expect(response).to have_http_status(:success)
  end

  it 'redirects update when not logged in' do
    patch user_path(admin), params: { user: { name: admin.name, email: admin.email } }

    expect(response).to redirect_to(login_url)
  end

  it 'redirects edit when not logged in' do
    get edit_user_path(admin)

    expect(response).to redirect_to(login_url)
  end

  it 'redirects edit when logged in as wrong user' do
    log_in_as(non_admin)
    get edit_user_path(admin)

    expect(response).to redirect_to(root_url)
    expect(flash).to be_empty
  end

  it 'redirects update when logged in as wrong user' do
    log_in_as(non_admin)
    patch user_path(admin), params: { user: { name: admin.name, email: admin.email } }

    expect(response).to redirect_to(root_url)
    expect(flash).to be_empty
  end

  it 'prevents admin attribute editing via the web' do
    log_in_as(non_admin)
    expect(non_admin.admin?).to be false

    patch user_path(non_admin), params: { user: { password: 'password', password_confirmation: 'password', admin: true } }

    expect(non_admin.reload.admin?).to be false
  end

  it 'redirects destroy when not logged in' do
    expect do
      delete user_path(admin)
    end.not_to change(User, :count)

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(login_url)
  end

  it 'redirects destroy when logged in as a non-admin' do
    log_in_as(non_admin)
    expect do
      delete user_path(admin)
    end.not_to change(User, :count)

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(root_url)
  end

  it 'redirects following when not logged in' do
    get following_user_path(admin)
    expect(response).to redirect_to(login_url)
  end

  it 'redirects followers when not logged in' do
    get followers_user_path(admin)
    expect(response).to redirect_to(login_url)
  end
end
