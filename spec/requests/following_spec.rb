require 'rails_helper'

RSpec.describe 'Following', type: :request do
  fixtures :all

  let(:user) { users(:michael) }
  let(:other) { users(:archer) }

  before do
    log_in_as(user)
  end

  it 'shows following page' do
    get following_user_path(user)
    expect(response).to have_http_status(:success)
    expect(user.following).not_to be_empty
    expect(response.body).to include(user.following.count.to_s)

    user.following.each do |followed|
      expect(response.body).to include(user_path(followed))
    end
  end

  it 'shows followers page' do
    get followers_user_path(user)
    expect(response).to have_http_status(:success)
    expect(user.followers).not_to be_empty
    expect(response.body).to include(user.followers.count.to_s)

    user.followers.each do |follower|
      expect(response.body).to include(user_path(follower))
    end
  end

  it 'shows feed on home page' do
    get root_path
    user.feed.paginate(page: 1).each do |micropost|
      expect(response.body).to include(CGI.escapeHTML(micropost.content))
    end
  end

  it 'follows a user the standard way' do
    expect do
      post relationships_path, params: { followed_id: other.id }
    end.to change(user.following, :count).by(1)

    expect(response).to redirect_to(other)
  end

  it 'follows a user with Hotwire' do
    expect do
      post relationships_path(format: :turbo_stream), params: { followed_id: other.id }
    end.to change(user.following, :count).by(1)
  end

  context 'unfollowing' do
    let!(:relationship) do
      user.follow(other)
      user.active_relationships.find_by(followed_id: other.id)
    end

    it 'unfollows a user the standard way' do
      expect do
        delete relationship_path(relationship)
      end.to change(user.following, :count).by(-1)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(other)
    end

    it 'unfollows a user with Hotwire' do
      expect do
        delete relationship_path(relationship, format: :turbo_stream)
      end.to change(user.following, :count).by(-1)
    end
  end
end
