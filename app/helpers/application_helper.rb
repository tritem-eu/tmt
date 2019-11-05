module ApplicationHelper
  include BasePresenter::ApplicationHelper
  include RailsExtras::Helpers::Tag

  V='0.0.0'

  def self.version
    V
  end

  # Return true when current_user is admin
  def logged_admin?
    return false unless current_user
    return current_user.has_role?(:admin)
  end

  # return breadcrumbs for the page
  def breadcrumbs(*paths)
    if paths[0] == :admin
      paths = paths.each_slice(2).to_a
      paths.delete_at(0)
      paths = [[t(:administration, scope: [:helpers, :application]), admin_path ]] + paths
    else
      paths = paths.each_slice(2).to_a
      paths = [[t(:home, scope: [:helpers, :application]), root_path ]] + paths
    end
    last_name, last_path = paths.pop
    add_tag(:nav) do |tag|
      tag << add_tag(:ul, class: "breadcrumb") do |tag|
        result = ""
        paths.each do |name, path|
          name = case name
          when :admin, :new, :edit, :projects, :campaigns, :campaign, :test_runs
            t(name, scope: [:helpers, :application])
          else
            name
          end
          if path.blank?
            tag << add_tag(:li, class: "active crop max-width20") { h(name) }
          else
            tag << add_tag(:li, class: "crop max-width20") { link_to(h(name), path) }
          end
        end
        tag << add_tag(:li, class: 'active crop max-width20') { h(last_name) }
      end
    end
  end

  def dropdown_menu_caret(options={}, &block)
    array = []
    sub_result = add_tag(:ul, class: "dropdown-menu dropdown-menu-hover #{options[:ul_class]}", role: 'menu') do |tag|
      block.call array
      array.each do |link|
        tag << add_tag(:li) do |tag|
          tag << link
        end
      end
    end

    resultat = add_tag(:div, class: 'btn-group dropdown') do |tag|
      disabled = (array.size == 0)
      tag << add_tag(:button, type: 'button', disabled: disabled, class: 'btn btn-default btn-xs dropdown-toggle', 'data-toggle' => 'dropdown') do
        add_tag(:span, class: "caret") {}
      end
      tag << sub_result
    end

    if array.any?
      resultat
    else
      popover({style: 'position: relative;'}, {content: options[:popover]}) do |tag|
        tag << resultat
      end
    end
  end

  def page_description(text)
    unless text.blank?
      add_tag do |tag|
        tag << add_tag(:p, class: 'description break-word crop', title: h(text)) do |tag|
          text.to_s.split("\n").each do |new_line|
            new_line.split("\t").each_with_index do |sub_line, index|
              tag << raw("&nbsp;&nbsp;") if index > 0
              tag << h(sub_line)
            end
            tag << raw("</br>")
          end
        end
        tag << icon('zoom-in', class: 'pull-right', style: 'margin: -30px 0px 10px 0')
      end
    end
  end

  def show_value(value)
    if value == true
      return 'True'
    elsif value == false
      return 'False'
    else
      if value.blank?
        add_tag(:i, class: 'text-muted') { "- None -" }
      else
        h(value)
      end
    end
  end

  # Return scaffold for title of page
  def page_header(title, attributes={})
    render '/helpers/page_header', title: title, attributes: attributes
  end

  def spinal_case(string)
    string.to_s.gsub("_", "-")
  end

  def render_modal(options={})
    class_name = options[:class_name]
    standard_class_name = "#{spinal_case(controller_name).gsub("tmt-", "")} #{spinal_case(action_name)}"
    signature = "#{spinal_case(controller_name)}-#{spinal_case(params[:action])}"

    j(add_tag(:div, class: "modal #{standard_class_name} #{class_name}", 'data-signature' => signature) do
      add_tag(:div, class: "modal-content") do |tag|
        tag << add_tag(:div, class: "modal-header") do |tag|
          tag << add_tag(:button,  raw("&times;"), type: "button", class: "close", 'data-dismiss' => "modal")
          tag << add_tag(:h3) do |tag|
            tag.space options[:header]
            if options[:subject]
              tag << add_tag(:small) do
                options[:subject].html_safe
              end
            end
          end
          if options[:right_side]
            tag << add_tag(:div, class: "pull-right") { options[:right_side] }
          end
          if options[:subheader]
            if options[:subheader] =~ /^<div/
              tag << options[:subheader]
            else
              tag << add_tag(:div, options[:subheader])
            end
          end
        end
        tag << add_tag(:div, class: "modal-body") do |tag|
          tag << render('/layouts/modal_messages')
          tag << options[:body]
        end
        tag << add_tag(:div, class: "modal-footer hide") { '' }
      end
    end)
  end

  def content_or_none(content=nil)
    unless content.blank?
      content
    else
      add_tag(:i, "- None -", class: 'text-muted')
    end
  end

  # this method cooperate with JS:app.dateTimePicker.add()
  def add_datetime(params={})
    if params[:type] == :date
      placeholder = "yyyy-mm-dd"
      js_hook = "js-date"
    else
      placeholder = "yyyy-mm-dd hh:mm:ss"
      js_hook = "js-datetime"
    end

    add_tag :div, class: "datetimepicker date input-group #{js_hook}" do |tag|
      attributes = {
        placeholder: placeholder,
        class: "form-control",
        readonly: params[:readonly]
      }
      if params[:f]
        if params[:value]
          attributes.merge!({value: params[:value].to_s.first(19)})
        end
        tag << params[:f].text_field(params[:name], attributes)
      else
        tag << text_field_tag(
          params[:name],
          params[:value].to_s.first(16),
          attributes
        )
      end

      tag << add_tag(:span, class: "input-group-addon add-on") do
        add_tag :i, '', {'data-time-icon' => 'glyphicon glyphicon-time', 'data-date-icon' => 'glyphicon glyphicon-calendar'}
      end
    end
  end

  def info_for_input(content)
    add_tag(:div, class: 'add-on-info text-info') do |tag|
      tag << add_tag(:a) { icon('info-sign') }
      tag << add_tag(:div, class: 'popover-info') do |tag|
        tag << add_tag(:p, class: 'popover-info-content') { content }
      end
    end
  end

  def info_point(content)
    add_tag(:div, class: 'text-info inline-block') do |tag|
      tag << add_tag(:a) { icon('info-sign') }
      tag << add_tag(:div, class: 'popover-info') do |tag|
        tag << add_tag(:p, class: 'popover-info-content') { content }
      end
    end

  end

  def project_sets_test_cases_path(project)
    member =  current_user.member_for_project(project)
    if member and member.get_nav_tab(:test_case) == :tree
      project_sets_path(project)
    else
      project_test_cases_path(project)
    end
  end

  def icon(name, options={})
    if options[:type] == :blue_big
      options[:style] = 'font-size: 70px; color: #789abc'
    end
    if options[:type] == 'size-10px'
      options[:style] = 'font-size: 10px; color: #789abc'
    end
    add_tag(:span, style: options[:style], class: "glyphicon glyphicon-#{name} #{options[:class]}") {}
  end

  def info(options={}, &block)
    add_tag(:div, class: 'text-center') do |tag|
      tag << add_tag(:h4) { options[:head] }
      tag << add_tag(:p, class: 'text-info') { options[:body] }
    end
  end

  def info_empty(options={}, &block)
    add_tag(:div, class: 'text-center') do |tag|
      if options[:head]
        tag << add_tag(:h4) { options[:head] }
      else
        tag << add_tag(:h4) { "No active #{options[:name]}" }
      end
      tag << add_tag(:p, class: 'text-info') do |tag|
        if logged_admin?
          tag << options[:admin_block]
        else
          tag.space(t :ask_your_admin_to_create, scope: :projects)
          tag << h(options[:name])
          tag << raw('<br />')
          tag << 'email: '
          User.admins.each_with_index do |user, index|
            tag << mail_to(user.email) do
              add_tag(:strong) do |tag|
                tag << ', '  unless index == 0
                tag << h(user.email)
              end
            end
          end
        end
      end
    end
  end

  # Information where user should ask an admin, who must do something
  def ask_admin(options={}, &block)
    if block_given?
      add_tag(:div, class: 'text-center') do |tag|
        tag << add_tag(:h4) { options[:head] }
        tag << add_tag(:p, class: 'text-info') do |tag|
          if logged_admin?
            tag << options[:admin_block]
          else
            tag.space('Ask your admin to')
            tag << h(options[:name])
            tag << raw('<br />')
            tag << 'email: '
            User.admins.each do |user|
              tag << mail_to(user.email)
            end
          end
        end
      end
    end
  end

  def projects_or_root_path
    if current_user and current_user.has_role?(:admin)
      admin_projects_path
    else
      root_path
    end
  end

  def button_submit_for(f, object_of_model, options={})
    options[:class] = "btn btn-primary in-modal-footer #{options[:class]}"
    name = ( object_of_model.id.nil? ? :create : :update )
    name = t(name, scope: [:helpers, :application])
    f.submit name, options
  end

  def link_with_description(options={})
    add_tag(:div, class: 'col-lg-4') do
      add_tag(:div, class: 'panel panel-default') do |tag|
        tag << add_tag(:div, class: 'panel-heading') do
          add_tag(:div, class: 'row') do |tag|
            tag << add_tag(:div, class: 'col-lg-2') do
              add_tag(:h1) do
                icon(options[:icon])
              end
            end
            tag << add_tag(:div, class: 'col-lg-10') do
              options[:description]
            end
          end
        end
        tag << link_to(options[:path]) do
          add_tag(:div, class: 'panel-footer announcement-bottom') do
            add_tag(:div, class: 'row') do |tag|
              tag << add_tag(:div, class: 'col-lg-8') do
                add_tag(:b) do
                  options[:name]
                end
              end
              tag << add_tag(:div, class: "col-lg-4 text-right") do
                icon('circle-arrow-right')
              end
            end
          end
        end
      end
    end
  end

  def crop_string(title, options={})
    if options[:mode]
      if options[:style]
        options[:style] << '; '
      else
        options[:style] = ''
      end
      options[:style] << 'display: inline-block;' if options[:mode].include?('inline')
      options[:style] << 'max-width: 20%;' if options[:mode].include?('width')
      options[:style] << 'max-width: 70%;' if options[:mode].include?('width70')

      value_px = options[:mode].to_s.scan(/width([0-9].*)px/).flatten.first
      if value_px
        options[:style] <<  "max-width: #{value_px}px;"
      end
    end
    add_tag(:div, h(title), class: "crop #{options[:class]}", title: h(title), style: options[:style])
  end

  def crop_text(*args)
    add_tag(:div) do |tag|
      args.each do |element|
        tag << add_tag(:div, class: "crop max-width20 inline-block") do |tag|
          tag << element
          tag << raw('&nbsp;')
        end
      end
    end
  end

  # input:
  #   headline - name of headline
  #   options:
  #     param_name - name of params to send (creator_ids[])
  #     selected_ids - array of active elements
  #     ids_and_amount - hash where key is id of record and value is number of records with this parameter
  #     ids_and_names - array with id of record and name of this record ([[1, 'admin'], ['2', 'john']])
  # output:
  #   facets of one category for searching
  def facets(headline, options)
    param_name = options[:param_name]
    selected_ids = options[:selected_ids] || []
    ids_count = options[:ids_and_amount] || {}
    return unless ids_count.any?
    show_names = options[:ids_and_names] || {}
    actives ||= []
    add_tag :div, class: 'panel panel-default' do |tag|
      tag << add_tag(:div, class: "panel-heading") do |tag|
        tag << add_tag(:h4, class: 'panel-title') do |tag|
          tag << headline
        end
      end
      tag << add_tag(:ul, class: "list-group") do |tag|
        ids_count.each do |object_id, count|
          tag << add_tag(:li, class: "list-group-item") do |tag|
            options = [false, :span, 'background-default']
            if selected_ids.include?(object_id.to_s)
              options = [true, :strong, 'background-grey']
            end
            tag.space check_box_tag("#{param_name}", object_id.to_s, options[0], id: nil, class: 'facets-checkbox')
            tag << add_tag(options[1], class: 'text-primary facets-name') do
              show_names[object_id.to_s] || object_id.to_s
            end
            tag << add_tag(:span, class: "badge pull-right #{options[2]}") do |tag|
              tag << count.to_s
            end
          end
        end
      end
    end
  end

  def pasta(object, *arguments)
    arguments.each do |method|
      object = object.method(method).call
    end
    object
  rescue
    nil
  end

  def options_of_select(collection, id, name, default, options={})
    add_tag do |tag|
      if options[:prompt]
        tag << add_tag(:option, value: '') do |tag|
          tag << options[:prompt]
        end
      end
      tag << options_from_collection_for_select(collection, id, name, default)
    end
  end

  # Inputs:
  #   collection - array or directory
  #   options - directory with keys like:
  #     value - position of collection which is value of option
  #     content - position of collection which will present
  #     default_value - selecting option which has same value like 'default value' option
  #     default_content - selecting option which has same content like 'default content' option
  #   data - directory of data variable to show
  # Example:
  #   add_options_of_select([[1, 'Red', 'yes'], [2, 'Green', 'no']],
  #     value: 0,
  #     content: 1,
  #     default_value: 2,
  #     data: {'display': 2}
  #   ) #=> "<option value='1' data-display='yes'>Red</option><option value='2' data-display='no'>Green</option>"
  def add_options_of_select(collection, options={})
    add_tag do |tag|
      collection.each do |element|
        value = element[options[:value]]
        content = element[options[:content]]
        if options[:additional_content]
          content += " (#{element[options[:additional_content]]})"
        end
        attributes = {value: value}
        if options[:data]
          options[:data].each do |key, position|
            attributes["data-#{key}"] = element[position]
          end
        end
        if options[:default_value] == value or options[:default_content] == content
          attributes[:selected] = :selected
        end
        tag << add_tag(:option, attributes) do |tag|
          tag << content
        end
      end
    end
  end

  def popover(options={}, data={}, &block)
    options = options.merge({
      'data-trigger' => 'hover',
      'data-toggle' => 'popover',
      'data-title' => data[:title],
      'data-placement' => data[:placement] || 'bottom',
      'data-content' => data[:content]
    })
    add_tag(:a, options) do |tag|
      yield(tag) if block_given?
    end
  end

  def long_datetime(time)
    l time, format: :long
  rescue
    nil
  end

  def t_or_not(name, options)
    t(name, options)
  rescue
    name
  end
end
