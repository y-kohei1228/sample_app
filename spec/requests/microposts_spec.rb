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

  it 'creates a reply when logged in' do
    log_in_as(users(:michael))
    parent = users(:michael).microposts.create!(content: 'Parent content')

    expect do
      post microposts_path, params: { micropost: { content: 'Reply content', parent_id: parent.id } }
    end.to change(Micropost, :count).by(1)

    expect(response).to redirect_to(parent)
    reply = Micropost.find_by(content: 'Reply content', parent_id: parent.id)
    expect(reply).to be_present
    expect(reply.parent).to eq(parent)
  end

  it 'destroys replies when a parent micropost is destroyed' do
    log_in_as(users(:michael))
    parent = users(:michael).microposts.create!(content: 'Parent content')
    parent.replies.create!(content: 'Reply content', user: users(:michael), parent: parent)

    expect do
      delete micropost_path(parent)
    end.to change(Micropost, :count).by(-2)

    expect(response).to have_http_status(:see_other)
    expect(Micropost.where(parent_id: parent.id)).to be_empty
  end
end
