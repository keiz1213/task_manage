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

  def submit_state(form, task)
    classes = %w[btn]
    case task.state
    when 'not_started'
      classes << 'btn-outline-secondary'
    when 'in_progress'
      classes << 'btn-outline-primary'
    when 'done'
      classes << 'btn-outline-success'
    end
    form.submit t("activerecord.attributes.task.states.#{task.state}"), data: { test: 'update-state'}, class: classes
  end
end
