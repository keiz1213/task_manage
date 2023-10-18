class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      reset_session
      remember(user)
      login(user)
      redirect_to tasks_path
    else
      flash.now[:danger] = 'パスワードまたはメールアドレスが間違っています'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout if logged_in?
    redirect_to login_path, status: :see_other
  end
end
