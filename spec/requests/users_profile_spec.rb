require 'rails_helper'

RSpec.describe 'Users profile', type: :request do
  fixtures :all

  let(:user) { users(:michael) }

  it 'shows profile display details' do
    get user_path(user)
    expect(response).to render_template('users/show')
    expect(response.body).to include(user.name)
    expect(response.body).to include('class="gravatar"')
    expect(response.body).to include(user.microposts.count.to_s)
    expect(response.body).to include('class="pagination"')

    user.microposts.paginate(page: 1).each do |micropost|
      expect(response.body).to include(micropost.content)
    end
  end

  it 'shows profile statistics' do
    get user_path(user)
    expect(response).to render_template('users/show')
    assert_select 'strong#following', text: user.following.count.to_s
    assert_select 'strong#followers', text: user.followers.count.to_s
  end
end
