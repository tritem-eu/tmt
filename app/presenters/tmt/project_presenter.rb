class Tmt::ProjectPresenter < ApplicationPresenter
  presents :project

  def subheader
    add_tag do |tag|
      tag.space(t :created_by, scope: :projects)
      tag.space(link_to h(project.creator_name), user_path(project.creator))
      tag.space(t(:created_at, scope: :projects))
      tag.add(l project.created_at, format: :medium)
    end
  end

  def created_at(format = :medium)
    return "" unless project.created_at
    l(project.created_at, format: format)
  end

  def link_to_new_test_case_small
    add_link new_project_test_case_path(project_id: project.id), class: 'btn btn-xs btn-primary', remote: true do |content|
      content.space icon('plus-sign')
      content << t(:new_test_case, scope: :test_cases)
    end
  end

  def link_to_new_campaign
    return if project.has_open_campaigns?
    link_new(new_admin_campaign_path(project_id: project.id), remote: true, title: t(:new_campaign, scope: :campaigns))
  end

  def link_to_new_test_run(class_name="btn")
    return unless project.open_campaign
    add_link new_project_campaign_test_run_path(project, project.open_campaign), remote: true, class: class_name do |content|
      content.space(icon 'plus-sign')
      content << t(:new_test_run, scope: :test_runs)
    end
  end

  def link_to_new_test_run_small
    return unless project.open_campaign
    link_to_new_test_run("btn btn-xs btn-primary")
  end

end
