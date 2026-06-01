require 'rails_helper'

RSpec.describe User, type: :model do
  fixtures :all

  let(:user) do
    User.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar12',
      password_confirmation: 'foobar12'
    )
  end

  it 'is valid' do
    expect(user).to be_valid
  end

  it 'requires a name' do
    user.name = ''
    expect(user).not_to be_valid
  end

  it 'requires an email' do
    user.email = ''
    expect(user).not_to be_valid
  end

  it 'rejects names that are too long' do
    user.name = 'a' * 51
    expect(user).not_to be_valid
  end

  it 'rejects emails that are too long' do
    user.email = "#{'a' * 244}@example.com"
    expect(user).not_to be_valid
  end

  it 'accepts valid email addresses' do
    valid_addresses = %w[
      user@example.com
      USER@foo.COM
      A_US-ER@foo.bar.org
      first.last@foo.jp
      alice+bob@baz.cn
    ]

    valid_addresses.each do |valid_address|
      user.email = valid_address
      expect(user).to be_valid, "#{valid_address.inspect} should be valid"
    end
  end

  it 'rejects invalid email addresses' do
    invalid_addresses = %w[
      user@example,com
      user_at_foo.org
      user.name@example.foo@bar_baz.com
      foo@bar+baz.com
      foo@bar..com
    ]

    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).not_to be_valid, "#{invalid_address.inspect} should be invalid"
    end
  end

  it 'requires a unique email address' do
    duplicate_user = user.dup
    user.save!
    expect(duplicate_user).not_to be_valid
  end

  it 'saves email addresses as lowercase' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    user.email = mixed_case_email
    user.save!
    expect(user.reload.email).to eq(mixed_case_email.downcase)
  end

  it 'rejects blank passwords' do
    user.password = user.password_confirmation = ' ' * 8
    expect(user).not_to be_valid
  end

  it 'requires a minimum password length' do
    user.password = user.password_confirmation = 'a' * 7
    expect(user).not_to be_valid
  end

  it 'authenticated? returns false for a user with nil digest' do
    expect(user.authenticated?(:remember, '')).to be false
  end

  it 'destroys associated microposts' do
    user.save!
    user.microposts.create!(content: 'Lorem ipsum')

    expect { user.destroy }.to change(Micropost, :count).by(-1)
  end

  it 'follows and unfollows a user' do
    michael = users(:michael)
    archer = users(:archer)

    expect(michael.following?(archer)).to be false
    michael.follow(archer)
    expect(michael.following?(archer)).to be true
    expect(archer.followers).to include(michael)
    michael.unfollow(archer)
    expect(michael.following?(archer)).to be false

    michael.follow(michael)
    expect(michael.following?(michael)).to be false
  end

  it 'includes the right posts in the feed' do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)

    lana.microposts.each do |post_following|
      expect(michael.feed).to include(post_following)
      expect(michael.feed.distinct).to eq(michael.feed)
    end

    michael.microposts.each do |post_self|
      expect(michael.feed).to include(post_self)
    end

    archer.microposts.each do |post_unfollowed|
      expect(michael.feed).not_to include(post_unfollowed)
    end
  end
end
