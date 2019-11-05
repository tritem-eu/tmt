class Tmt::TestCasePresenter < ApplicationPresenter
  presents :test_case

  def link_show(project=nil)
    project ||= test_case.project
    unless test_case.deleted_at.nil?
      link_to crop_string(test_case.name), project_test_case_path(project, test_case), class: 'is-deleted'
    else
      link_to crop_string(test_case.name), project_test_case_path(project, test_case)
    end
  end

  def text_show()
    if test_case.deleted_at.nil?
      crop_string(test_case.name)
    else
      crop_string(test_case.name, class: 'is-deleted')
    end
  end

  # show head name
  def header_name(options={})
    add_tag do |tag|
      if test_case.deleted_at.nil?
        tag << add_tag do
          path = toggle_steward_project_test_case_url(options[:project], test_case)
          if test_case.steward_id.nil?
            unlock_icon = fa_icon('unlock', class: 'text-success')
            link_to unlock_icon, path, method: :put, class: 'test_case_link_unlock'
          else
            title = ''
            title = h(options[:steward].email) if options[:steward]
            if can? :no_lock, test_case
              lock_icon = fa_icon('lock', class: 'text-success', title: title)
              link_to lock_icon, path, method: :put, class: 'test_case_link_lock'
            else
              fa_icon('lock', class: 'text-danger', title: title)
            end
          end
        end
      end
    end
  end

  def subheader
    add_tag do |tag|
      tag.space(t :created_by, scope: :test_cases)
      tag.space(link_to h(test_case.creator_name), user_path(test_case.creator))
      tag.space(t(:created_at, scope: :test_cases))
      tag.add(l test_case.created_at, format: :medium)
    end
  end

  def add_checkbox
    add_tag do |tag|
      if test_case.versions_count > 0
        tag.space add_tag(:input, type: 'checkbox', name: "test_case_ids[]", value: test_case.id, class: "check-test-case") {}
      else
        tag << popover({style: 'position: relative;'}, {content: 'This test case has not got versions'}) do |tag|
          tag << add_tag(:div, style: 'position: absolute; top: 0; left: 0; opacity: 0.5; height: 15px; width: 15px;') { '' }
          tag << add_tag(:input, type: 'checkbox', name: "test_case_ids[]", value: test_case.id, class: "check-test-case", readonly: "readonly", disabled: "disabled") {''}
        end
      end
    end
  end

  def self.add_submit_for_checkboxes(params, project, options={})
    campaign = project.open_campaign
    if campaign
      if params[:test_run_id]
        return form_for "", url: select_versions_project_campaign_executions_path(project, campaign, test_run_id: params[:test_run_id]), method: :get, remote: true, html: {class: "select-test-run hidden"} do |f|
          f.submit t(:add_to_test_run, scope: :test_cases), class: "check-test-case btn btn-primary"
        end
      else
        return form_for "", url: select_test_run_project_campaign_executions_path(project, campaign), method: :get, remote: true, html: {class: "select-test-run hidden"} do |f|
          f.submit t(:add_to_test_run, scope: :test_cases), class: "check-test-case btn btn-primary"
        end
      end
    else

    end
  end

  #private

  def link_external_relationship(external_relationship)
    add_tag do |tag|
      if external_relationship.kind == 'url'
        url = external_relationship.url
        value = external_relationship.value
        name = (value.blank? ? url : h(value))
        tag << link_to(name, url)
      else
        test_case = Tmt::TestCase.find(external_relationship.rq_id)
        name ||= test_case.name
        tag << test_case_link(test_case)
      end
    end
  end

end
