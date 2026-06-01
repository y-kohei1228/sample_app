require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  it 'returns the base title when no page title is given' do
    expect(helper.full_title).to eq('Ruby on Rails Tutorial Sample App')
  end

  it 'returns the full title when a page title is given' do
    expect(helper.full_title('Help')).to eq('Help | Ruby on Rails Tutorial Sample App')
  end
end
