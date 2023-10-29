class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy update_state]

  def index
    @tasks = @search_form.search(current_user).page(params[:page])
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
    @jointed_tag_names = @task.tags.pluck(:name).join(',')
  end

  def create
    @task = current_user.tasks.new(task_params)
    tag_list = Tag.build_tag_list(params[:task][:tag_name])
    if @task.save
      @task.save_tag(tag_list)
      flash.now[:success] = "タスク: #{@task.title}を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    tag_list = Tag.build_tag_list(params[:task][:tag_name])
    if @task.update(task_params)
      @task.save_tag(tag_list)
      flash.now[:success] = "タスク: #{@task.title}を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    flash.now[:success] = "タスク: #{@task.title}を削除しました"
  end

  def update_state
    @task.update_state
    render turbo_stream: turbo_stream.replace(@task, partial: 'state', locals: { task: @task })
  end

  private

  def set_task
    @task = current_user&.tasks&.find_by(id: params[:id])
    routing_error if @task.nil?
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :deadline, :state)
  end
end
