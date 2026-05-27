class PasswordResetsController < ApplicationController
  before_action :set_user,          only: %i[edit update]
  before_action :valid_user,        only: %i[edit update]
  before_action :check_expiration,  only: %i[edit update]

  def new; end

  def edit; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new', status: :unprocessable_content
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit', status: :unprocessable_content
    elsif @user.update(user_params)
      @user.forget
      reset_session
      log_in @user
      @user.update!(reset_digest: nil)
      @user.save!(validate: false)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[password password_confirmation])
  end

  # beforeフィルタ

  def set_user
    @user = User.find_by(email: params[:email])
  end

  # 有効なユーザーかどうか確認する
  def valid_user
    redirect_to root_url unless @user&.activated? && @user.authenticated?(:reset, params[:id])
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Password reset has expired.'
      redirect_to new_password_reset_url
    end
  end
end
