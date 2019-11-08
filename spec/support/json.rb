module JSONHelper
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JSONHelper, :type => :controller
end
