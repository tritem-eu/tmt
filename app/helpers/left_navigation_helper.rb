module LeftNavigationHelper
  # two ways of use:
  # - first (use only symbol)
  #   home_link_for_left_navigation # show link home
  #   home_link_for_left_navigation(active: true) # show link home and it will highlight
  # - second (use parameters)
  #   xyz_link_for_left_navigation(url: root_path, icon: 'glyphicon-home', active: true) # link to home with icon
  #   xyz_link_for_left_navigation(url: root_path, active: true) # link to home without icon
  def administration_link_for_left_navigation(options={})
    li_left_navigation(name: t(:administration, scope: :admin),
      url: admin_path,
      icon: 'glyphicon-cog',
      active: options[:active] == :admin
    )
  end

  def back_link_for_left_navigation(options={})
    li_left_navigation(name: t(:back, scope: [:helpers, :left_navigation]), url: nil, class: 'link-back', icon: 'glyphicon-chevron-left', disabled: :disabled)
  end

  def forward_link_for_left_navigation(options={})
    li_left_navigation(name: t(:forward, scope: [:helpers, :left_navigation]), url: 'javascript:app._forward()', icon: 'glyphicon-chevron-right')
  end

  def home_link_for_left_navigation(options={})
    li_left_navigation(name: t(:home, scope: [:helpers, :left_navigation]),
      url: root_path,
      icon: 'glyphicon-home',
      active: options[:active] == :home
    )
  end

  def edit_project_link_for_left_navigation(options={})
    li_left_navigation(name: t(:edit, scope: [:helpers, :left_navigation]),
      url: edit_admin_project_path(options[:project]),
      remote: true,
      active: options[:active],
      icon: 'glyphicon-pencil'
    )
  end

  def dashboard_link_for_left_navigation(options={})
    li_left_navigation(name: t(:dashboard, scope: [:helpers, :left_navigation]),
      url: project_path(options[:project]),
      icon: 'glyphicon-dashboard',
      active: options[:active] == :dashboard,
      nesting: 1
    )
  end

  def user_link_for_left_navigation(options={})
    li_left_navigation(name: h(options[:user].name),
      url: user_path(options[:user]),
      icon: 'glyphicon-user',
      active: options[:active]
    )
  end

  def campaign_link_for_left_navigation(options={})
    li_left_navigation(name: t(:campaign, scope: [:helpers, :left_navigation]),
      url: project_campaign_path(options[:project], options[:campaign]),
      icon: 'glyphicon-road',
      active: options[:active],
      nesting: 2
    )
  end

  def test_cases_link_for_left_navigation(options={})
    li_left_navigation(name: t(:test_cases, scope: [:helpers, :left_navigation]),
      url: project_sets_test_cases_path(options[:project]),
      icon: "glyphicon-list-alt",
      nesting: 2,
      active: options[:active] == :test_cases
    )
  end

  def machines_link_for_left_navigation(options={})
    li_left_navigation(name: t(:machines, scope: [:helpers, :left_navigation]),
      url: admin_machines_path,
      icon: "glyphicon-list-alt",
      nesting: 2,
      active: options[:active] == :machines
    )
  end

  def test_case_link_for_left_navigation(options={})
    li_left_navigation(name: h(options[:test_case].name),
      url: project_test_case_path(options[:project], options[:test_case]),
      fa_icon: 'file-text',
      active: options[:active] == :test_case,
      nesting: 3
    )
  end

  def edit_test_case_link_for_left_navigation(options={})
    li_left_navigation(name: t(:edit, scope: [:helpers, :left_navigation]),
      url: edit_project_test_case_path(options[:project], options[:test_case]),
      remote: true,
      icon: 'glyphicon-pencil',
      nesting: 4,
      active: options[:active] == [:test_case, :edit],
    )
  end

  def delete_test_case_link_for_left_navigation(options={})
    li_left_navigation(name: t(:delete, scope: [:helpers, :left_navigation]),
      url: project_test_case_path(options[:project], options[:test_case]),
      method: :delete,
      nesting: 4,
      icon: 'glyphicon-trash',
      class: 'hide-when-js-is-disabled'
    )
  end

  def test_runs_link_for_left_navigation(options={})
    project = options[:project]
    li_left_navigation(name: t(:all_test_runs, scope: :projects),
      url: project_test_runs_path(project, campaign_id: project.open_campaign),
      icon: 'glyphicon-tasks',
      active: options[:active] == :test_runs,
      nesting: 2
    )
  end

  def test_run_link_for_left_navigation(options={})
    li_left_navigation(name: h(options[:test_run].name),
      url: project_campaign_test_run_path(options[:project], options[:test_run].campaign, options[:test_run]),
      fa_icon: 'file-text',
      active: options[:active] == :test_run,
      nesting: 3
    )
  end

  def edit_test_run_link_for_left_navigation(options={})
    li_left_navigation(name: t(:edit, scope: [:helpers, :left_navigation]),
      url: edit_project_campaign_test_run_path(options[:project], options[:test_run].campaign, options[:test_run]),
      remote: true,
      icon: 'glyphicon-pencil',
      nesting: 4,
      active: options[:active] == [:test_run, :edit],
    )
  end

  def terminate_test_run_link_for_left_navigation(options={})
    li_left_navigation(name: t(:terminate, scope: :test_runs),
      url: terminate_project_test_run_path(options[:project], options[:test_run]),
      remote: false,
      icon: 'glyphicon-remove',
      nesting: 4,
      active: options[:active] == [:test_run, :terminate],
      data: { confirm: t(:are_you_sure, scope: [:helpers, :left_navigation]) }
    )
  end

  def clone_test_run_link_for_left_navigation(options={})
    li_left_navigation(name: t(:clone, scope: :test_runs),
      url: clone_project_test_run_path(options[:project], options[:test_run]),
      remote: false,
      fa_icon: 'columns',
      nesting: 4
    )
  end

  def execution_link_for_left_navigation(options={})
    if options[:active] == [:test_run, :execution]
      li_left_navigation(name: t(:execution, scope: :test_runs),
        url: project_campaign_execution_path(options[:project], options[:campaign], options[:execution]),
        nesting: 4,
        active: true,
        icon: 'glyphicon-record'
      )
    end
  end

  def delete_test_run_link_for_left_navigation(options={})
    li_left_navigation(name: t(:delete, scope: [:helpers, :left_navigation]),
      url: project_campaign_test_run_path(options[:project], options[:test_run].campaign, options[:test_run]),
      method: :delete,
      nesting: 4,
      icon: 'glyphicon-trash',
      class: 'hide-when-js-is-disabled'
    )
  end

  def statistics_link_for_left_navigation(options={})
    li_left_navigation(name: 'Statistics', url: request.fullpath, icon: 'glyphicon-stats', disabled: true)
  end

  ### left_navigation
  def left_navigation_for_dashboard(options={})
    set_current_project
    result = add_tag do |tag|
      tag << home_link_for_left_navigation(options)
      if current_user
        project = options[:project] || @current_project
        if project
          tag << dashboard_link_for_left_navigation(project: project, active: options[:active])
          tag << full_test_cases_for_left_navigation(project, @current_test_case, options)
          tag << full_test_runs_for_left_navigation(project, @current_test_run, options)
        end
        if options[:user]
          tag << user_link_for_left_navigation(user: options[:user], active: true)
        end
        if options[:campaign]
          tag << campaign_link_for_left_navigation(project: options[:project], campaign: options[:campaign], active: true)
        end
        tag << administration_link_for_left_navigation if current_user.admin?
      end
      tag << back_link_for_left_navigation
    end
    if options[:without_content_of_navigation]
      result
    else
      content_for :navigation do
        result
      end
    end
  end

  def left_navigation_for_admin(options={})
    content_for :navigation do
      add_tag do |tag|
        tag << home_link_for_left_navigation
        tag << administration_link_for_left_navigation(active: options[:active])
        [
          [:automation_adapters, t(:automation_adapters, scope: :admin), admin_automation_adapters_path, nil, "glyphicon glyphicon-facetime-video"],
          [:campaigns, t(:campaigns, scope: :admin), admin_campaigns_path, nil, "glyphicon glyphicon-road"],
          [:custom_fields, t(:custom_fields, scope: :admin), admin_test_case_custom_fields_path, admin_test_run_custom_fields_path,"glyphicon glyphicon-unchecked"],
          [:enumerations, t(:enumerations, scope: :admin), admin_enumerations_path,nil,"glyphicon glyphicon-sort-by-attributes"],
          [:cfg, t(:instance_configuration, scope: :admin), admin_cfgs_path, nil, "glyphicon glyphicon-cog"],
          [:machines, t(:machines, scope: :admin), admin_machines_path, nil, "glyphicon glyphicon-hdd"],
          [:members, t(:members, scope: :admin), admin_members_path, nil, "glyphicon glyphicon-link"],
          [:oslc_cfg, t(:oslc_configuration, scope: :admin), admin_oslc_cfgs_path, nil, "glyphicon glyphicon-cog"],
          [:projects, t(:projects, scope: :admin), projects_or_root_path, nil, "glyphicon glyphicon-folder-open"],
          [:test_case_types, t(:test_case_types, scope: :admin), admin_test_case_types_path, nil, "glyphicon glyphicon-file"],
          [:users, t(:users, scope: :admin), admin_users_path, nil, "glyphicon glyphicon-user"]
        ].each do |active, name, path, path2, icon_name|
          tag << li_left_navigation(name: name,
            url: path,
            nesting: 1,
            icon: icon_name,
            active: active == options[:active]
          )
        end
        tag << back_link_for_left_navigation
      end
    end
  end

  private

  def full_test_cases_for_left_navigation(project, test_case, options={})
    add_tag do |tag|
      if project
        tag << test_cases_link_for_left_navigation(project: project, active: options[:active])

        if test_case and test_case.deleted_at.nil?
          active = options[:active]
          active = [active] if active.class != Array
          tag << test_case_link_for_left_navigation(project: project, test_case: test_case, active: options[:active])
          if active.include?(:test_case)
            if can? :no_lock, test_case
              if test_case.deleted_at.nil?
                tag << edit_test_case_link_for_left_navigation(project: project, test_case: test_case, active: active)
                tag << delete_test_case_link_for_left_navigation(project: project, test_case: test_case)
              end
            end
          end
        end
      end
    end
  end

  def full_test_runs_for_left_navigation(project, test_run, options={})
    # test_run = options[:test_run] || test_run
    add_tag do |tag|
      project = options[:project] || @current_project
      if project
        tag << test_runs_link_for_left_navigation(project: project, active: options[:active])
        test_run = options[:test_run] || @current_test_run
        if test_run and test_run.deleted_at.nil?
          tag << test_run_link_for_left_navigation(project: project, test_run: test_run, active: options[:active])
          active = options[:active]
          active = [active] unless options[:active].class == Array
          if active.include?(:test_run)
            if test_run.deleted_at.nil?
              tag << execution_link_for_left_navigation(project: project, campaign: options[:test_run].campaign, execution: options[:execution], active: options[:active])
              if can? :editable, test_run
                tag << edit_test_run_link_for_left_navigation(project: project, test_run: test_run, active: active)
                tag << delete_test_run_link_for_left_navigation(project: project, test_run: test_run)
                if options[:show_upload_csv]
                  tag << upload_csv_test_run_link_for_left_navigation(project: project, test_run: test_run)
                end
              end
              unless test_run.project.open_campaign.nil?
                tag << clone_test_run_link_for_left_navigation(project: project, test_run: test_run, active: active)
              end
              if can? :terminate, @test_run
                tag << terminate_test_run_link_for_left_navigation(project: project, test_run: test_run, active: active)
              end
            end
          end
        end
      end
    end
  end

  def li_left_navigation(options={})
    class_name = 'navbar-panel'
    class_name << ' active' if options[:active]
    class_name << ' disabled' if options[:disabled]
    class_name << " #{options[:class]}" if options[:class]
    remote = options[:remote] || false
    add_tag(:li, class: "#{class_name}") do
      class_name = ""
      subresult = add_tag do |tag|
        nesting = (options[:nesting] || 0)*3
        tag << raw('&nbsp;'*nesting)
        tag << options[:content_before]
        tag << add_tag(:span, '', class: "glyphicon #{options[:icon]}") if options[:icon]
        tag << add_tag(:span, '', class: "fa fa-#{options[:fa_icon]}") if options[:fa_icon]
        tag << " "
        tag << crop_string(options[:name], mode: 'inline;width70')
        tag << " "
        tag << add_tag(:span, class: 'badge pull-right'){ options[:budge].to_s } if options[:budge]
      end
      options[:data] ||= {}
      unless options[:method]
        if options[:url]
          link_to options[:url], remote: remote, data: options[:data] do
            subresult
          end
        end
      else
        link_to options[:url], method: :delete, data: { confirm: t(:are_you_sure, scope: [:helpers, :left_navigation]) } do
          subresult
        end
      end
    end
  end

  def right_caret
    add_tag(:div, class: 'pull-right') do |tag|
      tag << add_tag(:b, '', class: "caret")
    end
  end

  def set_current_project
    if current_user
      @current_project = current_user.current_project
      if @current_project
        member = Tmt::Member.for_project(@current_project).where(user: current_user).first
        if member
          @current_test_run = member.current_test_run
          @current_test_case = member.current_test_case
        else
          @current_project = nil
        end
      end
    end
  end
end
