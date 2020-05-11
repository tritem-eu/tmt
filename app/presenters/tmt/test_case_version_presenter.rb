require 'converter'

module Tmt
  class TestCaseVersionPresenter < ApplicationPresenter
    presents :version

    def author
      author = version.author
      link_to h(author.name), user_path(author)
    end

    # Return size of file
    def file_size
      size = version.file_size.to_i
      if size < 2**10
        "#{size} bytes"
      elsif size < 2**20
        "#{size / 2**10} KB"
      else
        "#{size / 2**20} MB"
      end
    end

    def comment
      h(short_text(version.comment, 40))
    end

    def file_name
      h(short_text(version.file_name, 40))
    end

    def link_download(project, test_case)
      link_to file_name, download_project_test_case_version_path(project, test_case, version)
    end

    def link_show(project, test_case, options={})
      link_to comment, project_test_case_version_path(project, test_case, version), class: options[:class]
    end

    def link_with_id(project, test_case, options={})
      attributes = {class: options[:class]}
      add_tag(:div) do |tag|
        tag << add_link(project_test_case_version_path(project, test_case, version), attributes) do |tag|
          tag << version.id.to_s
          if not test_case.nil? and version.id == test_case.current_version_id
            tag << ' '
            tag << icon('leaf', type: 'size-10px')
          end
        end
        tag << add_tag(:div, class: 'popover-info') do |tag|
          tag << add_tag(:dl) do |tag|
            tag << add_tag(:dt) { t(:comment, scope: :test_case_versions) }
            tag << add_tag(:dd) { version.comment }
            tag << add_tag(:dt) { t(:file_name, scope: :test_case_versions) }
            tag << add_tag(:dd) { version.file_name }
          end
        end
      end
    end

    # Return icon 'load' or 'ok'
    def progress(project=nil, test_case=nil)
      unless version.revision.nil?
        add_tag(:span, "", class: "glyphicon glyphicon-ok")
      else
        url = ""
        url = progress_project_test_case_version_path(project, test_case, version) if test_case
        link_to url, remote: true do
          add_tag(:span, "", class: "load-icon")
        end
      end
    end

    def file_content
      test_case = version.test_case
      project = test_case.project
      add_tag(:div, class: 'file-content-wrapper') do
        add_tag(:div, class: "file-content") do |tag|
          tag << add_tag(:object,
            width: '100%',
            height: '100%',
            style: 'display: block',
            data: only_file_project_test_case_version_path(project, test_case, version),
            onload: 'app.executions.event.changeObjectTagHeight()'
          ) do
          end
        end
      end
    end

    def status
      :new
    end

    # Add form wher user can edit last content
    # present(new_version).edit_file_content(active_version)
    def edit_file_content(project, test_case, active_version)
      if version.id == null
        return nil
      end
      form_for(version, url: project_test_case_version_path(project, test_case, version), as: :test_case_version) do |f|
        add_tag do |tag|
          tag << f.hidden_field(:test_case_id)
          content = ""
          content = ::Tmt::Lib::Encoding.to_utf8(active_version.content) if active_version and active_version.id
          tag << f.text_area(:datafile, value: content, class: "form-control no-resize-vertical", rows: 7)
          tag << add_tag(:br, '')
          tag << add_tag(:div, class: "input-group") do |tag|
            comment = t(:default_comment, scope: :test_case_versions)
            comment = active_version.comment if active_version

            tag << f.text_field(:comment, value: comment, class: "form-control")
            tag << add_tag(:span, class: "input-group-btn" ) do
              f.submit(t(:save, scope: :test_case_versions), class: "btn btn-primary")
            end
          end
        end
      end
    end


    private

    def short_text(text, number = 15)
      text = text.to_s
      short_text = text.first(number)
      short_text << "..." if text.size > number
      add_tag(:span, short_text, title: text)
    end

  end
end
