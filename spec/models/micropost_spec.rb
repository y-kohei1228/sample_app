require 'rails_helper'

RSpec.describe Micropost, type: :model do
  fixtures :all

  before do
    @user = users(:michael)
    @micropost = @user.microposts.build(content: 'Lorem ipsum')
  end

  it 'is valid' do
    expect(@micropost).to be_valid
  end

  it 'requires a user id' do
    @micropost.user_id = nil
    expect(@micropost).not_to be_valid
  end

  it 'requires content' do
    @micropost.content = '   '
    expect(@micropost).not_to be_valid
  end

  it 'limits content to 140 characters' do
    @micropost.content = 'a' * 141
    expect(@micropost).not_to be_valid
  end

  it 'orders most recent first' do
    expect(Micropost.first).to eq(microposts(:most_recent))
  end

  it 'rejects invalid image content types' do
    @micropost.image.attach(
      io: StringIO.new('not an image'),
      filename: 'test.txt',
      content_type: 'text/plain'
    )

    expect(@micropost).not_to be_valid
  end
end
