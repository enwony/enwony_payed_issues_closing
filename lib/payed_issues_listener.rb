class ClosingHookListener < Redmine::Hook::ViewListener
  def view_issues_context_menu_start(context = {})
  
    # TODO to settings
    custom_id_payed = 6
    custom_id_counted = 7
    status_id_closed = 5
    
    projects = Issue.where(id: context[:issues]).group(:project_id).count
    if projects.size() == 1
      project_id, count = projects.first
      payto_issues = Issue
          .joins('LEFT JOIN custom_values counted on counted.customized_id = issues.id and counted.custom_field_id = %d' % [custom_id_counted])
          .joins('LEFT JOIN custom_values payed on payed.customized_id = issues.id and payed.custom_field_id = %d' % [custom_id_payed])
          .select('issues.id AS id, issues.subject AS subject, counted.value AS counted, payed.value AS payed')
          .where(["project_id = ? and status_id <> ? AND IFNULL(payed.value, 0) > IFNULL(counted.value, 0)", project_id, status_id_closed])
          .order("created_on DESC")
      core = {controller: 'closing', action: 'change', ids: context[:issues]}
      title = l(:do_close)
      content = payto_issues.collect{|i| "<li>" + link_to(h(link_to_issue(i)), url_for(core.merge({payto: i.id})), {:class => 'icon'}) + "</li>"}.join
    else
      title = l(:error_different_projects)
    end
  end
  return '<ul><a href="#" class="submenu">%s</a>%s</ul>' % [title, content]
end
