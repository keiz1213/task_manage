class Admin::UsersController < ApplicationController
  skip_before_action :set_search_form
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.preload(:tasks)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "ユーザー: #{@user.name}を登録しました"
      redirect_to admin_users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = "ユーザー: #{@user.name}を更新しました"
      redirect_to admin_users_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "ユーザー: #{@user.name}を削除しました"
    redirect_to admin_users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
