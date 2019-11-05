class Tmt::TestCaseSearcher < ApplicationSearcher

  def initialize(options)
    @project = options[:project]
    @user = options[:user]
    @params = options[:params]
    @member = @user.member_for_project(@project)
    @model = ::Tmt::TestCase
    @controller = options[:controller]
  end

  def search
    return @search if @search
    update_filter

    test_case = @model.arel_table
    test_cases = @project.undeleted_test_cases.includes(:custom_field_values)
    request = test_case[:name].matches("%#{@filter['search']}%".gsub('*', '%').gsub('?', '_').gsub('.', '_'))
    request = request.and(test_case[:type_id].in(@filter['type_ids'])) if @filter['type_ids']
    request = request.and(test_case[:creator_id].in(@filter['creator_ids'])) if @filter['creator_ids']
    if @filter['custom_fields']
      custom_field_value = Tmt::TestCaseCustomFieldValue.arel_table
      custom_field = nil
      @filter['custom_fields'].each do |custom_field_id, values|
        ids = Tmt::TestCaseCustomFieldValue.where(custom_field_value[:custom_field_id].eq(custom_field_id).and(custom_field_value[:bool_value].in(values))).map(&:test_case_id)
        custom_field ||= ids
        custom_field = custom_field & ids
      end
      request = request.and(test_case[:id].in(custom_field))
    end
    with_filter = test_cases.where(request)
    last_page = with_filter.size / Tmt::Cfg.first.records_per_page
    last_page += 1 unless with_filter.size % Tmt::Cfg.first.records_per_page == 0
    @params['page'] = last_page.to_s if last_page <= @params['page'].to_i

    with_filter = with_filter.page(@params['page']).per(Tmt::Cfg.first.records_per_page)

    @search = {
      with_filter: with_filter,
      without_filter: test_cases
    }
  end

  def update_filter
    return @filter if @filter
    filters = @member.filters
    filters ||= {}
    result = filters[:test_case] || {}
    unless @params['save_filter_params'] == 'true'
      result = {}
    end
    @params.delete('save_filter_params')

    if @params['search'] or @params['creator_ids'] or @params['type_ids'] or @params['custom_fields']
      result['search'] = @params['search']
      result['creator_ids'] = @params['creator_ids']
      result['type_ids'] = @params['type_ids']
      result['custom_fields'] = @params['custom_fields']
    end
    filters[:test_case] = result
    @member.update(filters: filters)
    @filter = @member.filters[:test_case]
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
        selected_ids: @filter['creator_ids'],
        ids_and_amount: without_filter.group(:creator_id).count,
        ids_and_names: array_to_hash(User.all.pluck :id, :name)
      }
    when :type
      {
        param_name: 'type_ids[]',
        selected_ids: @filter['type_ids'],
        ids_and_amount: without_filter.group(:type_id).count,
        ids_and_names: array_to_hash(Tmt::TestCaseType.undeleted.pluck :id, :name)
      }
    when :custom_field
      custom_field = options[:custom_field]
      if custom_field.type_name == 'bool'
        ids_and_amount = without_filter.where(Tmt::TestCaseCustomFieldValue.arel_table[:custom_field_id].eq(custom_field.id)).group(:bool_value).count
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
