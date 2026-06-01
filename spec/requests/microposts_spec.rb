require 'rails_helper'

RSpec.describe 'Microposts', type: :request do
  fixtures :all

  let(:micropost) { microposts(:orange) }

  it 'redirects create when not logged in' do
    expect do
      post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
    end.not_to change(Micropost, :count)

    expect(response).to redirect_to(login_url)
  end

  it 'redirects destroy when not logged in' do
    expect do
      delete micropost_path(micropost)
    end.not_to change(Micropost, :count)

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(login_url)
  end

  it 'redirects destroy for wrong micropost' do
    log_in_as(users(:michael))
    wrong_micropost = microposts(:ants)

    expect do
      delete micropost_path(wrong_micropost)
    end.not_to change(Micropost, :count)

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(root_url)
  end
end
