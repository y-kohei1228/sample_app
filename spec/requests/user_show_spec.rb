require 'rails_helper'

RSpec.describe 'User show', type: :request do
  fixtures :all

  let(:inactive_user) { users(:inactive) }
  let(:activated_user) { users(:archer) }

  it 'redirects when the user is not activated' do
    get user_path(inactive_user)
    expect(response).to redirect_to(root_url)
  end

  it 'displays the user when activated' do
    get user_path(activated_user)
    expect(response).to have_http_status(:success)
    expect(response).to render_template('users/show')
  end
end
