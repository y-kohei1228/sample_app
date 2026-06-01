require 'rails_helper'

RSpec.describe 'Users signup', type: :request do
  fixtures :all

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'does not sign up with invalid information' do
    expect do
      post users_path, params: {
        user: { name: '', email: 'user@invalid', password: 'foo', password_confirmation: 'bar' }
      }
    end.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response).to render_template('users/new')
    expect(response.body).to include('div id="error_explanation"')
    expect(response.body).to include('div class="field_with_errors"')
  end

  it 'signs up with valid information and sends activation email' do
    expect do
      post users_path, params: {
        user: { name: 'Example User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
      }
    end.to change(User, :count).by(1)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  context 'account activation' do
    let(:email_body) do
      post users_path, params: {
        user: { name: 'Example User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
      }
      ActionMailer::Base.deliveries.last.body.encoded
    end

    let(:new_user) do
      email_body
      User.find_by(email: 'user@example.com')
    end

    let(:activation_token) { email_body.match(%r{account_activations/(.+?)/edit})[1] }

    it 'is not activated initially' do
      expect(new_user.activated?).to be false
    end

    it 'does not log in before activation' do
      log_in_as(new_user)
      expect(is_logged_in?).to be false
    end

    it 'rejects activation with invalid token' do
      get edit_account_activation_path('invalid token', email: new_user.email)
      expect(is_logged_in?).to be false
    end

    it 'rejects activation with valid token and wrong email' do
      get edit_account_activation_path(activation_token, email: 'wrong')
      expect(is_logged_in?).to be false
    end

    it 'activates with valid token and email' do
      get edit_account_activation_path(activation_token, email: new_user.email)
      expect(new_user.reload.activated?).to be true
      follow_redirect!
      expect(response).to render_template('users/show')
      expect(is_logged_in?).to be true
    end
  end
end
