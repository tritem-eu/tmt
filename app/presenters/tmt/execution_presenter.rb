module Tmt
  class ExecutionPresenter < ApplicationPresenter

    presents :execution

    def result_label(project)
      case execution.status
      when 'passed', 'failed', 'error'
        link_to report_project_campaign_execution_path(project, execution.test_run.campaign, execution) do
          status_label
        end
      else
        status_label
      end
    end

    def result_content
      attached_file = execution.attached_files.first
      if attached_file.present?
        campaign = execution.campaign
        project = campaign.project
        is_binary = File.binary?(attached_file[:server_path])
        content = attached_file[:compressed_file].decompress if attached_file[:compressed_file]
        add_tag(:div, class: 'file-content-wrapper') do
          add_tag(:div, class: "file-content") do |tag|
            tag << add_tag(:span, class: 'file-name') do
              attached_file[:original_filename]
            end
            tag << add_tag(:object,
              width: '100%',
              height: '100%',
              style: 'display: block',
              data: report_file_project_campaign_execution_path(project, campaign, execution),
              onload: 'app.executions.event.changeObjectTagHeight()'
            ) do
            end
          end
        end
      end
    end

    def progress
      if execution.progress
        "#{execution.progress} %"
      else
        content_or_none
      end
    end

    def attached_file_links(project=nil)
      attached_files = execution.attached_files
      campaign = nil
      if attached_files.any?
        add_tag do |tag|
          attached_files.each do |attached_file|
            campaign ||= execution.campaign
            project ||= campaign.project
            url = download_attached_file_project_campaign_execution_path project, campaign, execution, attached_file[:uuid]
            tag << link_to(url) do
              add_tag do |tag|
                tag << icon('paperclip')
                tag << h(attached_file[:original_filename])
                tag << add_tag(:br) {}
              end
            end
          end
        end
      else
        content_or_none
      end
    end

    private

    def status_label
      class_name = case execution.status
      when 'passed' then 'background-passed'
      when 'failed' then 'background-failed'
      when 'executing' then 'background-executing'
      when 'error' then 'background-error'
      else
        'label-default'
      end

      add_tag :span, class: "label #{class_name}" do
        execution.status || t(:execution_result_none, scope: :test_runs)
      end
    end
  end
end
