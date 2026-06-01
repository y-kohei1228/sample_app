require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  fixtures :all

  let(:user) { users(:michael) }

  describe 'account activation' do
    let(:activation_token) { User.new_token }
    let(:mail) do
      user.activation_token = activation_token
      UserMailer.account_activation(user)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Account activation')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['kohei.yoshikawa1228@gmail.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(user.name)
      expect(mail.body.encoded).to include(activation_token)
      expect(mail.body.encoded).to include(CGI.escape(user.email))
    end
  end

  describe 'password reset' do
    let(:reset_token) { User.new_token }
    let(:mail) do
      user.reset_token = reset_token
      UserMailer.password_reset(user)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Password reset')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['kohei.yoshikawa1228@gmail.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(reset_token)
      expect(mail.body.encoded).to include(CGI.escape(user.email))
    end
  end
end
