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

  it 'allows a reply to a micropost' do
    parent = @user.microposts.create!(content: 'Parent content')
    reply = @user.microposts.build(content: 'Reply content', parent: parent)

    expect(reply).to be_valid
    expect(reply.parent).to eq(parent)
  end

  it 'rejects replies deeper than the maximum thread depth' do
    max_depth = Micropost::MAX_THREAD_DEPTH
    root = @user.microposts.create!(content: 'Root')
    parent = (2..max_depth).reduce(root) do |prev, _|
      @user.microposts.create!(content: 'Reply', parent: prev)
    end
    too_deep = @user.microposts.build(content: 'Too deep', parent: parent)

    expect(too_deep).not_to be_valid
    expect(too_deep.errors[:parent]).to include("thread depth must be #{max_depth} levels or less")
  end

  it 'returns replies using the replies scope' do
    parent = @user.microposts.create!(content: 'Parent content')
    reply = @user.microposts.create!(content: 'Reply content', parent: parent)

    expect(Micropost.replies).to include(reply)
    expect(Micropost.replies).not_to include(parent)
  end

  it 'returns a thread using the thread scope' do
    root = @user.microposts.create!(content: 'Root')
    direct_reply = @user.microposts.create!(content: 'Direct reply', parent: root)
    other = @user.microposts.create!(content: 'Other content')

    expect(Micropost.thread(root)).to include(root, direct_reply)
    expect(Micropost.thread(root)).not_to include(other)
  end

  it 'destroys replies when the parent micropost is destroyed' do
    parent = @user.microposts.create!(content: 'Parent content')
    reply = @user.microposts.create!(content: 'Reply content', parent: parent)

    expect { parent.destroy }.to change(Micropost, :count).by(-2)
    expect(Micropost.exists?(reply.id)).to be_falsey
  end
end
