class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy update_state]
  before_action :logged_in_user

  def index
    @tasks = @search_form.search(current_user).page(params[:page])
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      flash[:success] = "タスク: #{@task.title}を作成しました"
      redirect_to tasks_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      flash[:success] = "タスク: #{@task.title}を更新しました"
      redirect_to tasks_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    flash[:success] = "タスク: #{@task.title}を削除しました"
    redirect_to tasks_url
  end

  def update_state
    @task.update_state
    render turbo_stream: turbo_stream.replace(@task, partial: 'state', locals: { task: @task })
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :deadline, :state)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = 'ログインしてください'
      redirect_to login_url, status: :see_other
    end
  end
end
