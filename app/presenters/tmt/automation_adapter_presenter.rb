class Tmt::AutomationAdapterPresenter < ApplicationPresenter
  presents :adapter

  def link_user
    user = adapter.user
    name = h content_or_none(user.name)
    link_to name, [user], target: :_blank
  end

  def link_project
    project = adapter.project
    name = h content_or_none(project.name)
    link_to name, [project], target: :_blank
  end

  def name
    h content_or_none(adapter.name)
  end

  def type
    h content_or_none(adapter.adapter_type)
  end

  def polling_interval
    h content_or_none(adapter.polling_interval)
  end

  def description
    h content_or_none(adapter.description)
  end

  def link_update
    link_edit(edit_admin_automation_adapter_url(adapter))
  end
end
