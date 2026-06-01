require 'rails_helper'

RSpec.describe 'Users edit', type: :request do
  fixtures :all

  let(:user) { users(:michael) }

  it 'does not update with invalid information' do
    log_in_as(user)
    get edit_user_path(user)
    expect(response).to render_template('users/edit')

    patch user_path(user), params: {
      user: { name: '', email: 'foo@invalid', password: 'foo', password_confirmation: 'bar' }
    }

    expect(response).to render_template('users/edit')
    expect(response.body).to include('class="alert alert-danger"')
    expect(response.body).to include('The form contains 4 errors.')
  end

  it 'updates successfully with friendly forwarding' do
    get edit_user_path(user)
    log_in_as(user)
    expect(response).to redirect_to(edit_user_url(user))

    name = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(user), params: { user: { name: name, email: email, password: '', password_confirmation: '' } }

    expect(flash[:success] || flash[:notice]).not_to be_nil
    expect(response).to redirect_to(user)
    user.reload
    expect(user.name).to eq(name)
    expect(user.email).to eq(email)
  end

  it 'friendly forwarding works only on the first login' do
    get edit_user_path(user)
    expect(response).to redirect_to(login_url)

    log_in_as(user)
    expect(response).to redirect_to(edit_user_url(user))
    expect(session[:forwarding_url]).to be_nil

    delete logout_path
    log_in_as(user)
    expect(response).to redirect_to(user)
  end
end
