require 'rails_helper'

RSpec.describe 'Static pages', type: :request do
  fixtures :all

  let(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  it 'renders home' do
    get root_path
    expect(response).to have_http_status(:success)
    expect(response.body).to match(%r{<title>#{base_title}</title>})
  end

  it 'renders help' do
    get help_path
    expect(response).to have_http_status(:success)
    expect(response.body).to match(%r{<title>Help \| #{base_title}</title>})
  end

  it 'renders about' do
    get about_path
    expect(response).to have_http_status(:success)
    expect(response.body).to match(%r{<title>About \| #{base_title}</title>})
  end

  it 'renders contact' do
    get contact_path
    expect(response).to have_http_status(:success)
    expect(response.body).to match(%r{<title>Contact \| #{base_title}</title>})
  end
end
