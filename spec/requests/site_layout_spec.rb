require 'rails_helper'

RSpec.describe 'Site layout', type: :request do
  fixtures :all

  let(:user) { users(:michael) }

  it 'shows layout links when not logged in' do
    get root_path
    expect(response).to render_template('static_pages/home')
    expect(response.body.scan(/href="#{Regexp.escape(root_path)}"/).count).to eq(2)
    expect(response.body).to include("href=\"#{help_path}\"")
    expect(response.body).to include("href=\"#{login_path}\"")
    expect(response.body).to include("href=\"#{about_path}\"")
    expect(response.body).to include("href=\"#{contact_path}\"")
    expect(response.body).to include("href=\"#{signup_path}\"")
    expect(response.body).not_to include("href=\"#{users_path}\"")

    get contact_path
    expect(response.body).to include('<title>Contact |')

    get signup_path
    expect(response.body).to include('<title>Sign up |')
  end

  it 'shows layout links when logged in' do
    log_in_as(user)
    get root_path
    expect(response).to render_template('static_pages/home')
    expect(response.body.scan(/href="#{Regexp.escape(root_path)}"/).count).to eq(2)
    expect(response.body).to include("href=\"#{help_path}\"")
    expect(response.body).not_to include("href=\"#{login_path}\"")
    expect(response.body).to include("href=\"#{logout_path}\"")
    expect(response.body).to include("href=\"#{about_path}\"")
    expect(response.body).to include("href=\"#{contact_path}\"")
    expect(response.body).not_to include("href=\"#{signup_path}\"")
    expect(response.body).to include("href=\"#{user_path(user)}\"")
    expect(response.body).to include("href=\"#{users_path}\"")
    expect(response.body).to include("href=\"#{edit_user_path(user)}\"")
  end

  it 'shows correct home page stats' do
    log_in_as(user)
    get root_path
    expect(response.body).to include("href=\"#{following_user_path(user)}\"")
    expect(response.body).to include(user.following.count.to_s)
    expect(response.body).to include("href=\"#{followers_user_path(user)}\"")
    expect(response.body).to include(user.followers.count.to_s)
  end
end
