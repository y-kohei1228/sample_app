require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  fixtures :all

  let(:user) { users(:michael) }

  before do
    helper.remember(user)
  end

  it 'returns the current user when remember digest is valid' do
    expect(helper.current_user).to eq(user)
    expect(session[:user_id]).to eq(user.id)
  end

  it 'returns nil when remember digest is invalid' do
    user.update!(remember_digest: User.digest(User.new_token))
    expect(helper.current_user).to be_nil
  end
end
