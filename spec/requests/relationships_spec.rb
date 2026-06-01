require 'rails_helper'

RSpec.describe 'Relationships', type: :request do
  fixtures :all

  it 'requires a logged-in user to create a relationship' do
    expect do
      post relationships_path
    end.not_to change(Relationship, :count)

    expect(response).to redirect_to(login_url)
  end

  it 'requires a logged-in user to destroy a relationship' do
    expect do
      delete relationship_path(relationships(:one))
    end.not_to change(Relationship, :count)

    expect(response).to redirect_to(login_url)
  end
end
