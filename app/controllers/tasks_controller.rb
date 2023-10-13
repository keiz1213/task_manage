class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  def index
    task_sort = TaskSort.new(sort_params)
    @tasks = task_sort.result
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

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :deadline, :state)
  end

  def sort_params
    params[:sort].present? ? params.require(:sort).permit(:sort_by) : {}
  end
end
