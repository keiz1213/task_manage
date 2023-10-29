module TasksHelper
  def priority_badge(task)
    classes = %w[badge rounded-pill my-auto py-2]
    case task.priority
    when 'low'
      classes << 'bg-primary-subtle text-primary-emphasis'
    when 'mid'
      classes << 'bg-warning-subtle text-warning-emphasis'
    when 'high'
      classes << 'bg-danger-subtle text-danger-emphasis'
    end
    tag.span(class: classes) { "重要度: #{t("activerecord.attributes.task.priorities.#{task.priority}")}" }
  end

  def submit_state(form, task)
    classes = %w[btn w-100 p-2]
    case task.state
    when 'not_started'
      classes << 'btn-outline-secondary'
    when 'in_progress'
      classes << 'btn-outline-primary'
    when 'done'
      classes << 'btn-outline-success'
    end
    form.submit t("activerecord.attributes.task.states.#{task.state}"), data: { test: 'update-state' }, class: classes
  end

  def link_to_search_by_state(text, state, search_form)
    classes = %w[btn]
    classes << 'active' if search_form.state == state
    case state
    when 'not_started'
      classes << 'btn-outline-secondary'
    when 'in_progress'
      classes << 'btn-outline-primary'
    when 'done'
      classes << 'btn-outline-success'
    end
    link_to text, tasks_path(search: { keyword: search_form.keyword, sort_by: search_form.sort_by, state: state, tag_name: search_form.tag_name }),
            method: 'get', class: classes
  end

  def link_to_search_by_tag_name(tag_name, search_form)
    classes = %w[badge me-1 mb-1 text-decoration-none fs-6]
    search_form.tag_name == tag_name ? classes << 'text-bg-primary' : classes << 'text-bg-secondary'

    link_to tag_name, tasks_path(search: { keyword: search_form.keyword, sort_by: search_form.sort_by, state: search_form.state, tag_name: tag_name }),
            method: 'get', class: classes
  end
end
