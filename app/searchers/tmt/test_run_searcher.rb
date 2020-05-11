class Tmt::TestRunSearcher < ApplicationSearcher

  def initialize(options)
    @project = options[:project]
    @user = options[:user]
    @params = options[:params]
    @action = options[:action]
    @member = @user.member_for_project(@project)
    @model = ::Tmt::TestRun
    # @date = {due_date: ['2013', '3'], created_at: ['2014', '9', '2']}
    @date = options[:date] || {}
  end

  def search
    return @search if @search
    update_filter

    test_run = @model.arel_table
    request = test_run[:name].matches("%#{@filter['search']}%".gsub('*', '%').gsub('?', '_').gsub('.', '_'))
    request = request.and(test_run[:campaign_id].in(@project.campaign_ids))
    @date.each do |key, array|
      if array.size == 3
        year, month, day = array.map(&:to_i)
        start_date = Date.new(year, month, day).to_s
        end_date = Date.new(year, month, day).next_day.to_s
        request = request.and(test_run[key].lt(end_date))
        request = request.and(test_run[key].gteq(start_date))
      elsif array.size == 2
        year, month = array.map(&:to_i)
        start_date = Date.new(year, month).to_s
        end_date = Date.new(year, month).next_month.to_s
        request = request.and(test_run[key].lt(end_date))
        request = request.and(test_run[key].gteq(start_date))
      end
    end
    test_runs = @model.includes(:custom_field_values).undeleted.where(request)

    request = request.and(test_run[:status].in(@filter['status_ids'])) if @filter['status_ids']
    request = request.and(test_run[:creator_id].in(@filter['creator_ids'])) if @filter['creator_ids']
    request = request.and(test_run[:campaign_id].in(@filter['campaign_ids'])) if @filter['campaign_ids']
    if @filter['custom_fields']
      custom_field_value = Tmt::TestRunCustomFieldValue.arel_table
      custom_field = nil
      @filter['custom_fields'].each do |custom_field_id, values|
        ids = Tmt::TestRunCustomFieldValue.where(custom_field_value[:custom_field_id].eq(custom_field_id).and(custom_field_value[:bool_value].in(values))).map(&:test_run_id)
        custom_field ||= ids
        custom_field = custom_field & ids
      end
      request = request.and(test_run[:id].in(custom_field))
    end
    with_filter = test_runs.where(request)
    last_page = with_filter.size / Tmt::Cfg.first.records_per_page
    last_page += 1 unless with_filter.size % Tmt::Cfg.first.records_per_page == 0
    @params['page'] = last_page.to_s if last_page <= @params['page'].to_i

    if @date.empty?
      with_filter = with_filter.page(@params['page']).per(Tmt::Cfg.first.records_per_page)
    end

    @search = {
      with_filter: with_filter,
      without_filter: test_runs
    }
  end

  def update_filter
    return @filter if @filter
    filters = @member.filters
    filters ||= {}
    result = filters[:test_run] || {}
    unless @params['save_filter_params'] == 'true'
      result = {}
    end
    @params.delete('save_filter_params')

    if @params['search'] or @params['creator_ids'] or @params['status_ids'] or @params['campaign_ids'] or @params['custom_field']
      result['search'] = @params['search']
      result['creator_ids'] = @params['creator_ids']
      result['status_ids'] = @params['status_ids']
      result['campaign_ids'] = @params['campaign_ids']
      result['custom_fields'] = @params['custom_fields']
    end
    if @date
      result['date'] = @date
    end
    filters[:test_run] = result
    @member.update(filters: filters)
    @filter = @member.filters[:test_run]
  end

  def filter
    update_filter
    @filter
  end

  def options_for_facets(category, options={})
    case category
    when :creator
      {
        param_name: 'creator_ids[]',
        selected_ids: filter['creator_ids'],
        ids_and_amount: without_filter.group(:creator_id).count,
        ids_and_names: array_to_hash(User.all.pluck :id, :name)
      }
    when :campaign
      {
        param_name: 'campaign_ids[]',
        selected_ids: filter['campaign_ids'],
        ids_and_amount: without_filter.group(:campaign_id).count,
        ids_and_names: array_to_hash(Tmt::Campaign.all.pluck :id, :name)
      }
    when :status
      {
        param_name: 'status_ids[]',
        selected_ids: filter['status_ids'],
        ids_and_amount: without_filter.group(:status).count,
        ids_and_names: array_to_hash(Tmt::TestRun.statuses.to_a)
      }
    when :custom_field
      return {}
      custom_field = options[:custom_field]
      if custom_field.type_name == 'bool'
        ids_and_amount = without_filter.where(Tmt::TestRunCustomFieldValue.arel_table[:custom_field_id].eq(custom_field.id)).group(:bool_value).count
        {
          param_name: "custom_fields[#{custom_field.id}][]",
          selected_ids: (@filter['custom_fields'] and @filter['custom_fields'][custom_field.id.to_s]),
          ids_and_amount: ids_and_amount,
          ids_and_names: array_to_hash([[1, 'True'], [0, 'False'], ['t', 'True'], ['f', 'False'], [nil, 'None'], ['', 'None']])
        }
      else
        nil
      end
    else
      {}
    end
  end

end
