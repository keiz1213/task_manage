class Admin::UsersController < ApplicationController
  def index
    @user = User.new
    @users = User.all
  end

  def show
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "ユーザー: #{@user.name}を登録しました"
      redirect_to admin_users_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
