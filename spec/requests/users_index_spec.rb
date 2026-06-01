require 'rails_helper'

RSpec.describe 'Users index', type: :request do
  fixtures :all

  let(:admin) { users(:michael) }
  let(:non_admin) { users(:archer) }

  context 'as admin' do
    before do
      log_in_as(admin)
      get users_path
    end

    it 'renders the index page' do
      expect(response).to render_template('users/index')
    end

    it 'paginates users' do
      expect(response.body).to include('class="pagination"')
    end

    it 'shows delete links for other users' do
      User.where(activated: true).paginate(page: 1).each do |user|
        expect(response.body).to include(user_path(user))
        expect(response.body).to include(user.name)
        expect(response.body).to include('delete') unless user == admin
      end
    end

    it 'deletes a non-admin user' do
      expect do
        delete user_path(non_admin)
      end.to change(User, :count).by(-1)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(users_url)
    end

    it 'displays only activated users' do
      user = User.paginate(page: 1).first
      user.update!(activated: false)
      get users_path

      expect(response.body).not_to include(user.name)
    end
  end

  context 'as non-admin' do
    it 'does not show delete links' do
      log_in_as(non_admin)
      get users_path
      assert_select 'a', text: 'delete', count: 0
    end
  end
end
