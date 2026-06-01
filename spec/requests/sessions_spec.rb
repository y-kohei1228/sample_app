require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  it 'renders the login page' do
    get login_path
    expect(response).to have_http_status(:success)
  end
end
