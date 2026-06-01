require 'rails_helper'

RSpec.describe 'Users login', type: :request do
  fixtures :all

  let(:user) { users(:michael) }

  context 'with invalid password' do
    it 'renders the login page' do
      get login_path
      expect(response).to render_template('sessions/new')
    end

    it 'does not log in with invalid credentials' do
      post login_path, params: { session: { email: user.email, password: 'invalid' } }
      expect(is_logged_in?).to be false
      expect(response).to render_template('sessions/new')
      expect(flash[:danger] || flash[:alert] || flash[:notice]).not_to be_nil

      get root_path
      expect(flash[:danger] || flash[:alert] || flash[:notice]).to be_nil
    end
  end

  context 'with valid login' do
    before do
      post login_path, params: { session: { email: user.email, password: 'password' } }
    end

    it 'logs in successfully' do
      expect(is_logged_in?).to be true
      expect(response).to redirect_to(user)
    end

    it 'redirects to profile after login' do
      follow_redirect!
      expect(response).to render_template('users/show')
      expect(response.body).not_to include(login_path)
      expect(response.body).to include(logout_path)
      expect(response.body).to include(user_path(user))
    end
  end

  context 'logout' do
    before do
      post login_path, params: { session: { email: user.email, password: 'password' } }
      delete logout_path
    end

    it 'logs out successfully' do
      expect(is_logged_in?).to be false
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_url)
    end

    it 'redirects to root after logout' do
      follow_redirect!
      expect(response.body).to include(login_path)
      expect(response.body).not_to include(logout_path)
      expect(response.body).not_to include(user_path(user))
    end

    it 'still works after logout in a second window' do
      delete logout_path
      expect(response).to redirect_to(root_url)
    end
  end

  context 'remembering' do
    it 'remembers users when remember_me is checked' do
      log_in_as(user, remember_me: '1')
      expect(cookies[:remember_token]).not_to be_blank
    end

    it 'forgets users when remember_me is not checked' do
      log_in_as(user, remember_me: '1')
      log_in_as(user, remember_me: '0')
      expect(cookies[:remember_token]).to be_blank
    end
  end
end
