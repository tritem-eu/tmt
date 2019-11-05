module LinksHelper
  include RailsExtras::Helpers::Tag

  def link_delete_for_custom_field(custom_field)
    link_delete(
      custom_field_path(custom_field),
      confirm: 'This action destroy all records which use this custom fields. This operation can take a few minutes! Are you sure?'
    )
  end

  def link_delete(path, options={})
    class_name = options[:class] || 'btn'
    class_name << ' hide-when-js-is-disabled'
    if options[:only_show]
      return add_link nil, class: class_name, method: :delete, disabled: :disabled, rel: nil do |content|
        content.space(icon 'trash')
        content << t(:delete, scope: [:helpers, :links])
      end
    end

    if options[:object]
      return nil unless options[:object].deleted_at
    end
    add_link path, class: class_name, method: :delete, data: {confirm: options[:confirm] || 'Are you sure?'}, remote: options[:remote] || false, rel: nil do |content|
      content.space(icon 'trash')
      content << t(:delete, scope: [:helpers, :links])
    end
  end

  def link_with_icon(path, options={})
    add_link path, class: "btn", remote: options[:remote] do |content|
      if options[:glyphicon]
        content.space icon(options[:glyphicon])
      end
      if options[:fa_icon]
        content.space fa_icon(options[:fa_icon])
      end
      content << options[:name]
    end
  end

  def link_edit(path, options={})
    if options[:object]
      return nil unless options[:object].deleted_at.nil?
    end
    options[:remote] = true if options[:remote].nil?
    options[:name] ||= h(t(:edit, scope: [:helpers, :links]))
    class_name = "btn #{options[:class]}"
    add_link path, class: class_name, remote: options[:remote] do |content|
      content.space icon('pencil')
      content << options[:name]
    end
  end

  def link_new(path, options={})
    options[:remote] = true if options[:remote].nil?
    options[:class] = "btn #{options[:class]}"
    options[:name] ||= h(t(:new, scope: [:helpers, :links]))
    add_link path, options do |content|
      content.space(icon 'plus-sign')
      content << options[:name]
    end
  end

  def link_back(path=:back, options={})
    options[:remote] = false if options[:remote].nil?
    add_link path, class: "btn", remote: options[:remote] do |content|
      content.space icon('circle-arrow-left')
      content << 'Back'
    end
  end

  def link_user(user)
    return unless user
    user = User.where(id: user).first if user.class == ::Fixnum
    if user
      add_link user_path(user) do |tag|
        tag.space(user.machine? ? icon("th") : icon("user"))
        tag << h(user.name)
      end
    end
  end

  def test_case_version_link(version, test_case=nil, project=nil)
    test_case ||= version.test_case
    project ||= test_case.project
    add_tag do |tag|
      url = project_test_case_version_path(project, test_case, version)
      tag << link_to(h(version.comment), url)
    end
  end

  def campaign_link(campaign, attributes={})
    add_tag do |tag|
      tag << link_to(h(campaign.name), project_campaign_path(campaign.project, campaign), attributes)
      tag << add_tag(:div, class: 'popover-info') do |tag|
        tag << add_tag(:dl, class: 'dl-vertical') do |tag|
          tag << add_tag(:dt) {t(:is_open, scope: [:helpers, :links])}
          tag << add_tag(:dd) {campaign.is_open ? "True": "False"}
          tag << add_tag(:dt) {t(:created_at, scope: [:helpers, :links])}
          tag << add_tag(:dd) {present(campaign).created_at}
          tag << add_tag(:dt) {t(:deadline_at, scope: [:helpers, :links])}
          tag << add_tag(:dd) {present(campaign).deadline_at}
        end
      end
    end
  end

  def test_run_link(test_run, path=nil)
    path ||= project_test_run(test_run.project, test_run)
    class_name = 'is-deleted' unless test_run.deleted_at.blank?
    link_to h(test_run.name), path, class: class_name
  end

  def test_case_link(test_case, path=nil)
    path ||= project_test_case_path(test_case.project_id, test_case)
    class_name = 'is-deleted' unless test_case.deleted_at.blank?
    link_to h(test_case.name), path, class: class_name
  end

  def project_link(project, options={})
    link_to h(project.name), project_path(project), options
  end
end
