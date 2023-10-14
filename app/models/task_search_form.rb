class TaskSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sort_by, :string
  attribute :keyword, :string
  attribute :priority, :string

  def sort_task
    case sort_by
    when 'deadline'
      Task.deadline
    else
      Task.recent
    end
  end

  def narrow_down_by_priority(sorted_tasks)
    case priority
    when 'not_started'
      sorted_tasks.not_started
    when 'in_progress'
      sorted_tasks.in_progress
    when 'done'
      sorted_tasks.done
    end
  end

  def search
    sorted_tasks = sort_task
    sorted_tasks = sorted_tasks.matches(keyword) if keyword.present?
    sorted_tasks = narrow_down_by_priority(sorted_tasks) if priority.present?
    sorted_tasks
  end
end
