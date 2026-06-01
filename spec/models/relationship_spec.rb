require 'rails_helper'

RSpec.describe Relationship, type: :model do
  fixtures :all

  let(:relationship) do
    Relationship.new(
      follower_id: users(:michael).id,
      followed_id: users(:archer).id
    )
  end

  it 'is valid' do
    expect(relationship).to be_valid
  end

  it 'requires a follower_id' do
    relationship.follower_id = nil
    expect(relationship).not_to be_valid
  end

  it 'requires a followed_id' do
    relationship.followed_id = nil
    expect(relationship).not_to be_valid
  end
end
