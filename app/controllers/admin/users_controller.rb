class Admin::UsersController < ApplicationController
  skip_before_action :set_search_form
  before_action :require_admin
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.preload(:tasks).recent
  end

  def show
    @tasks = @user.tasks.recent.page(params[:page])
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash.now[:success] = "ユーザー: #{@user.name}を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      flash.now[:success] = "ユーザー: #{@user.name}を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      if request.referer.match? %r{/admin/users/\d+}
        flash[:success] = "ユーザー: #{@user.name}を削除しました"
        redirect_to admin_users_path
      else
        flash.now[:success] = "ユーザー: #{@user.name}を削除しました"
      end
    else
      flash.now[:danger] = @user.errors.full_messages[0]
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin
    routing_error unless current_user.admin?
  end
end
