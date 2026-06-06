require 'rails_helper'

RSpec.describe MicropostsController, type: :controller do
  fixtures :all

  let(:user) { users(:michael) }

  describe 'POST #create' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:logged_in?).and_return(true)
    end

    it 'creates a micropost with parent_id' do
      parent = user.microposts.create!(content: 'Parent content')

      expect do
        post :create, params: { micropost: { content: 'Reply content', parent_id: parent.id } }
      end.to change(Micropost, :count).by(1)

      expect(response).to redirect_to(micropost_path(parent))
      expect(assigns(:micropost).parent).to eq(parent)
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:logged_in?).and_return(true)
    end
    it 'destroys the micropost when correct user is logged in' do
      session[:user_id] = user.id
      micropost = user.microposts.create!(content: 'Delete me')

      expect do
        delete :destroy, params: { id: micropost.id }
      end.to change(Micropost, :count).by(-1)

      expect(response).to redirect_to(root_url)
    end
  end
end
