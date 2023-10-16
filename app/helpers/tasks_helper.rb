module TasksHelper
  def priority_badge(task)
    classes = %w[badge rounded-pill my-auto py-2]
    case task.priority
    when 'low'
      classes << 'text-bg-primary'
    when 'mid'
      classes << 'text-bg-warning'
    when 'high'
      classes << 'text-bg-danger'
    end
    tag.span(class: classes) { '重要度: ' + t("activerecord.attributes.task.priorities.#{task.priority}") }
  end
end
