class Tmt::UserActivityPresenter < ApplicationPresenter
  presents :user_activity

  def activity_for_observable
    activity_wrapper do |tag|
      tag.space link_user(user_activity.user)
      tag << activity_root(active_subject: false).to_s
    end
  end

  def activity_for_user
    activity_wrapper do |tag|
      tag.space activity_root(active_subject: true).to_s
    end
  end

  def activity_for_project
    activity_wrapper do |tag|
      tag.space link_user(user_activity.user)
      tag.space activity_root(active_subject: true).to_s
    end
  end

  private

  def activity_wrapper(&block)
    add_tag :tr do |tag|
      tag << add_tag(:td, class: 'col-lg-10', style: 'border-right: 0px') do
        add_tag(:small) do
          add_tag { |tag| block.call(tag) }
        end
      end

      tag << add_tag(:td, class: 'col-lg-2', style: 'border-left: 0px') do
        add_tag(:small, class: 'pull-right') do |tag|
          tag.space icon('time')
          tag.space time_ago_in_words(user_activity.created_at)
          tag << 'ago'
        end
      end
    end
  rescue => e
    add_tag :tr do |tag|
      tag << add_tag(:td, class: 'col-lg-12', colspan: 2) do
        "User activity object with id: #{user_activity.id} #{e.message} is incorrect"
      end
    end
  end

  def activity_root(options={})
    add_tag do |tag|
      user_activity_params = user_activity.params
      case user_activity_params[:parser]
      when :uploaded_version
        tag.space(I18n.t(:uploaded, scope: :user_activities))
        file_name = Base64.decode64(user_activity_params[:file_name])
        file_name = Tmt::Lib::Encoding.to_utf8(file_name)
        file_name = crop_string(file_name, mode: 'inline;width')

        version_id = user_activity_params[:version_id]
        url = project_test_case_version_path(user_activity.project, user_activity.observable, version_id)

        tag.space(add_tag :i, link_to(file_name, url))
        tag.space('as a new version')
        if options[:active_subject]
          tag.space "on"
          tag.space activity_subject
        end
      when :deleted_observable
        tag.space crop_string(' removed', mode: 'inline')
        tag.space activity_subject
      else
        if user_activity.before_value.blank?
          unless user_activity.after_value.blank?
            tag.space crop_string(' set value of', mode: 'inline')
            tag.space(add_tag :b, crop_string(user_activity.param_name, mode: 'inline;width'))
            tag.space crop_string('to', mode: 'inline')
            tag.space(add_tag :i, crop_string(user_activity.after_value, mode: 'inline;width'))
          end
        else
          if user_activity.after_value.blank?
            tag.space ' removed value of'
            tag.space add_tag(:b, crop_string(user_activity.param_name, mode: 'inline'))
          else
            tag.space crop_string(' changed', mode: 'inline')
            tag.space add_tag(:b, crop_string(user_activity.param_name, mode: 'inline'))
            tag.space crop_string('from', mode: 'inline')
            value = (user_activity.before_value || 'nil')
            tag.space add_tag(:i, crop_string(value, mode: 'inline;width'))
            tag.space crop_string('to', mode: 'inline')
            tag.space add_tag(:i, crop_string(user_activity.after_value || 'nil', mode: 'inline;width'))
          end
        end
        if options[:active_subject]
          tag.space "on"
          tag.space activity_subject
        end
      end
    end
  end

  def activity_subject
    observable = user_activity.observable
    add_tag do |tag|
      class_name = ''
      case user_activity.observable_type
      when "Tmt::TestCase"
        tag.space t(:test_case, scope: :test_cases)
        class_name = 'is-deleted' unless observable.deleted_at.blank?
        tag << link_to(h(observable.name), [observable.project, observable], class: class_name)
      when "Tmt::TestRun"
        class_name = 'is-deleted' unless observable.deleted_at.blank?
        tag.space t(:test_run, scope: :test_runs)
        tag << link_to(h(observable.name), [observable.project, observable.campaign, observable], class: class_name)
      else
      end
    end
  end

end
