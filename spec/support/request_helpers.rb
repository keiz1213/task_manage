module RequestHelpers
  def login_as(user, remember_me: true)
    remember_me = remember_me ? '1' : '0'
    post login_path, params: { session: { email: user.email, password: user.password, remember_me: remember_me }}
  end

  def is_logged_in?
    !session[:user_id].nil?
  end
end
