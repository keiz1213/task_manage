class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy update_state]

  def index
    @tasks = @search_form.search.page(params[:page])
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
      redirect_to tasks_path, notice: "タスク: #{@task.title}を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: "タスク: #{@task.title}を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_url, notice: "タスク: #{@task.title}を削除しました"
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
end
