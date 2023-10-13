class TaskSort
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sort_by, :string

  def sort
    sort_by == 'deadline' ? Task.deadline : Task.recent
  end
end
