require 'rails_helper'

RSpec.describe 'Password resets', type: :request do
  fixtures :all

  let(:user) { users(:michael) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'displays the password reset form' do
    get new_password_reset_path
    expect(response).to render_template('password_resets/new')
    expect(response.body).to include('name="password_reset[email]"')
  end

  it 're-renders with invalid email' do
    post password_resets_path, params: { password_reset: { email: '' } }
    expect(flash[:danger] || flash[:alert] || flash[:notice]).not_to be_nil
    expect(response).to render_template('password_resets/new')
  end

  context 'after requesting password reset' do
    let(:reset_email) do
      post password_resets_path, params: { password_reset: { email: user.email } }
      ActionMailer::Base.deliveries.last
    end

    let(:reset_user) do
      reset_email
      User.find_by(email: user.email)
    end

    let(:reset_token) { reset_email.body.encoded.match(%r{password_resets/(.+?)/edit})[1] }

    it 'sends reset email for valid email' do
      expect(reset_user.reset_digest).not_to eq(user.reset_digest)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(flash[:info] || flash[:notice]).not_to be_nil
      expect(response).to redirect_to(root_url)
    end

    it 'redirects when email is wrong' do
      get edit_password_reset_path(reset_token, email: '')
      expect(response).to redirect_to(root_url)
    end

    it 'redirects inactive users' do
      reset_user.update!(activated: false)
      get edit_password_reset_path(reset_token, email: reset_user.email)
      expect(response).to redirect_to(root_url)
    end

    it 'redirects when token is wrong' do
      get edit_password_reset_path('wrong token', email: reset_user.email)
      expect(response).to redirect_to(root_url)
    end

    it 'renders the reset form with correct token and email' do
      get edit_password_reset_path(reset_token, email: reset_user.email)
      expect(response).to render_template('password_resets/edit')
      expect(response.body).to include('name="email"')
      expect(response.body).to include("value=\"#{reset_user.email}\"")
    end

    context 'updating the password' do
      before do
        get edit_password_reset_path(reset_token, email: reset_user.email)
      end

      it 'renders errors with invalid password and confirmation' do
        patch password_reset_path(reset_token), params: {
          email: reset_user.email,
          user: { password: 'foobaz12', password_confirmation: 'barquux' }
        }
        expect(response.body).to include('div id="error_explanation"')
      end

      it 'renders errors with empty password' do
        patch password_reset_path(reset_token), params: {
          email: reset_user.email,
          user: { password: '', password_confirmation: '' }
        }
        expect(response.body).to include('div id="error_explanation"')
      end

      it 'updates with valid password and confirmation' do
        patch password_reset_path(reset_token), params: {
          email: reset_user.email,
          user: { password: 'foobaz12', password_confirmation: 'foobaz12' }
        }
        expect(is_logged_in?).to be true
        expect(flash[:success] || flash[:notice]).not_to be_nil
        expect(response).to redirect_to(reset_user)
        expect(reset_user.reload.reset_digest).to be_nil
      end
    end
    context 'with expired token' do
      before do
        reset_user.update!(reset_sent_at: 3.hours.ago)
        patch password_reset_path(reset_token), params: {
          email: reset_user.email,
          user: { password: 'foobaz12', password_confirmation: 'foobaz12' }
        }
      end

      it 'redirects to the password reset page' do
        expect(response).to redirect_to(new_password_reset_url)
      end

      it 'shows expired message' do
        follow_redirect!
        expect(response.body).to match(/expired/i)
      end
    end
  end
end
