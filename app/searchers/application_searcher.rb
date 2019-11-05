class ApplicationSearcher

  def initialize(options)
    @project = options[:project]
    @user = options[:user]
    @params = options[:params]
    @action = options[:action]
    @member = @user.member_for_project(@project)
    #@model =
  end

  def search
  end

  def with_filter
    search[:with_filter]
  end

  def without_filter
    search[:without_filter]
  end

  def update_search_filter
  end

  def options_for_facets(category)
  end

  private

  # array_to_hash([['1', 'name'], [2, 'beta']]) #=> {
  #   '1' => 'name',
  #   '2', 'beta'
  # }
  def array_to_hash(array)
    result = {}

    array.each do |id, value|
      result[id.to_s] = value.to_s
    end

    result
  end

end
