class SessionsController < ApplicationController
  skip_before_action :logged_in_user
  skip_before_action :set_search_form

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      reset_session
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      login(user)
      flash[:success] = 'ログインしました'
      redirect_to forwarding_url || tasks_path
    else
      flash.now[:danger] = 'パスワードまたはメールアドレスが間違っています'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout if logged_in?
    flash[:success] = 'ログアウトしました'
    redirect_to login_path, status: :see_other
  end
end
