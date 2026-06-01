require 'rails_helper'

RSpec.describe 'Microposts interface', type: :request do
  fixtures :all

  let(:user) { users(:michael) }

  before do
    log_in_as(user)
  end

  it 'paginates microposts on the home page' do
    get root_path
    expect(response.body).to include('class="pagination"')
  end

  it 'does not create a micropost with invalid submission' do
    expect do
      post microposts_path, params: { micropost: { content: '' } }
    end.not_to change(Micropost, :count)

    expect(response.body).to include('div id="error_explanation"')
    expect(response.body).to include('href="/?page=2"')
  end

  it 'creates a micropost with valid submission' do
    content = 'This micropost really ties the room together'

    expect do
      post microposts_path, params: { micropost: { content: content } }
    end.to change(Micropost, :count).by(1)

    expect(response).to redirect_to(root_url)
    follow_redirect!
    expect(response.body).to include(content)
  end

  it 'shows delete links on own profile page' do
    get user_path(user)
    assert_select 'a', text: 'delete'
  end

  it 'deletes own micropost' do
    first_micropost = user.microposts.paginate(page: 1).first
    expect do
      delete micropost_path(first_micropost)
    end.to change(Micropost, :count).by(-1)
  end

  it 'does not show delete links on another user profile page' do
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  it 'displays the correct micropost count in the sidebar' do
    get root_path
    expect(response.body).to include("#{user.microposts.count} microposts")
  end

  it 'shows zero microposts when appropriate' do
    log_in_as(users(:malory))
    get root_path
    expect(response.body).to include('0 microposts')
  end

  it 'shows one micropost when appropriate' do
    log_in_as(users(:lana))
    get root_path
    expect(response.body).to include('1 micropost')
  end

  it 'shows an image upload field' do
    get root_path
    assert_select 'input[type="file"]'
  end

  it 'attaches an image to a micropost' do
    content = 'This micropost really ties the room together.'
    img = fixture_file_upload(Rails.root.join('spec/fixtures/files/kitten.jpg'), 'image/jpeg')

    expect do
      post microposts_path, params: { micropost: { content: content, image: img } }, as: :multipart
    end.to change(Micropost, :count).by(1)

    micropost = Micropost.order(created_at: :desc).first
    expect(micropost.image).to be_attached
  end
end
