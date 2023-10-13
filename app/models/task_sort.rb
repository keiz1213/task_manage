class TaskSort
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sort_by, :string

  def result
    case sort_by
    when 'deadline'
      Task.deadline
    else
      Task.recent
    end
  end
end
