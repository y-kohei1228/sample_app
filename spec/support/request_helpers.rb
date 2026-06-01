module RequestHelpers
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: {
      session: {
        email: user.email,
        password: password,
        remember_me: remember_me
      }
    }
  end

  def is_logged_in?
    !session[:user_id].nil?
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
