class TaskSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sort_by, :string
  attribute :keyword, :string

  def sort
    case sort_by
    when 'deadline'
      Task.deadline
    else
      Task.recent
    end
  end

  def search
    sorted_tasks = sort
    sorted_tasks = sorted_tasks.matches(keyword) if keyword.present?
    sorted_tasks
  end
end