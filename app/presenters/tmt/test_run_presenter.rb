module Tmt
  class TestRunPresenter < ApplicationPresenter
    presents :test_run

    def due_date(format = :medium)
      date = test_run.due_date
      return content_or_none unless date
      l(date, format: format)
    end

    def created_at(format = :medium)
      date = test_run.created_at
      return content_or_none unless date
      l(date, format: format)
    end

    # return link to profil of creator
    def link_creator
      user = test_run.creator
      link_to h(user.name), user_path(user)
    end

    def link_clone(project)
      link_with_icon([:clone, project, test_run],
        name: t(:clone, scope: :test_runs),
        fa_icon: 'columns'
      )
    end

    def execution_progress(options={})
      statuses_counter = test_run.executions_statuses_counter
      unit = 1
      unit = 100.0 / test_run.executions.size if test_run.executions.size > 0
      statuses_counter.each_pair { |key, value|  statuses_counter[key] *= unit }
      style = ""
      style = 'height: 4px; margin: 5px' if options[:type] == :thin
      add_tag(:div, class: 'progress progress-striped', style: style) do |tag|
        tag << add_tag(:div, class: 'progress-bar progress-bar-default background-passed', style: "width: #{statuses_counter[:passed]}%") do
          add_tag(:span, class: 'sr-only') { "#{statuses_counter[:passed]} % Complete (success)" }
        end
        tag << add_tag(:div, class: 'progress-bar progress-bar-default background-failed', style: "width: #{statuses_counter[:failed]}%") do
          add_tag(:span, class: 'sr-only') { "#{statuses_counter[:failed]} % Complete (exec)" }
        end
        tag << add_tag(:div, class: 'progress-bar progress-bar-default background-error', style: "width: #{statuses_counter[:error]}%") do
          add_tag(:span, class: 'sr-only') { "#{statuses_counter[:error]} % Complete (info)" }
        end
        tag << add_tag(:div, class: 'progress-bar progress-bar-default background-executing', style: "width: #{statuses_counter[:executing]}%") do
          add_tag(:span, class: 'sr-only') { "#{statuses_counter[:executing]} % Complete (warn)" }
        end
      end
    end

    def link_to_report(project, campaign)
      if test_run.status == 4
        add_link report_project_campaign_test_run_path(project, campaign, test_run, format: :pdf), class: 'btn btn-primary' do |content|
          content.space icon('download-alt')
          content << t(:report, scope: :test_runs)
        end
      end
    end

    # return link to edit
    def link_edit(project, campaign)
      link_to t(:edit, scope: :test_runs), edit_project_campaign_test_run_path(project, campaign, test_run), remote: true
    end

    # return link to profil of executor
    def link_executor
      user = test_run.executor
      if user
        link_to h(user.name), user_path(user)
      else
        add_tag(:i, "- None -")
      end
    end

    # return link to campaign view
    def link_to_campaign
      campaign = test_run.campaign
      link_to h(campaign.name), admin_campaign_path(campaign)
    end

    # return name of test run
    def name
      h(test_run.name || "---")
    end

    def status
      t(test_run.status_name, scope: [:test_runs, :_status])
    end

    def status_small
      result = case test_run.status
      when 1 then "default"
      when 2 then "info"
      when 3 then "primary"
      when 4 then "success"
      else
        "default"
      end
      add_tag(:div, class: "label label-#{result}", style: "width: 50px !important") do
        status
      end
    end

    def background_css
      [
        'background-status-new',
        'background-status-new',
        'background-status-planned',
        'background-status-executing',
        'background-status-done'
      ][test_run.status.to_i]
    end

    def due_time
      test_run.due_date.strftime("%H:%M")
    end
  end
end
