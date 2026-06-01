require 'rails_helper'

RSpec.describe 'Account activations', type: :request do
  fixtures :all

  it 'activates a valid account' do
    user = users(:inactive)
    user.activation_token = User.new_token
    user.update!(activation_digest: User.digest(user.activation_token))

    get edit_account_activation_path(user.activation_token, email: user.email)

    expect(user.reload).to be_activated
    expect(response).to redirect_to(user)
  end
end
