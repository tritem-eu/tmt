require 'spec_helper'

describe Oslc::Core::Routes do
  let(:routes) do
    Oslc::Core::Routes.new
  end

  after do
    Oslc::Core::Routes.new()
  end

  it "should be covered method by Routes class (method can be used without arguments)" do
    expect do
      routes.oslc_automation_service_provider_request_url
    end.to_not raise_error
  end

  it "should show url where are used two arguments" do
    result = routes.oslc_automation_service_provider_request_url(1, 1)
    result.should include server_url('/oslc/automation/service-providers/1/requests/1')
  end

  it "should show URL when is added additional parameter to URL" do
    result = routes.oslc_automation_service_provider_request_url(1, 1, is_active: true)
    result.should include server_url('/oslc/automation/service-providers/1/requests/1?is_active=true')
  end

  it "should change port and host of URL" do
    routes = Oslc::Core::Routes.new({
      port: 3013,
      host: '127.0.0.1'
    })
    routes.oslc_user_url(1).should eq 'http://127.0.0.1:3013/oslc/users/1'
  end

  it "should change port and host and protocol of URL" do
    routes = Oslc::Core::Routes.new({
      port: 3013,
      host: '127.0.0.1',
      protocol: 'https'
    })
    routes.oslc_user_url(1).should eq 'https://127.0.0.1:3013/oslc/users/1'
  end

  it "should change host and script_name of URL" do
    routes = Oslc::Core::Routes.new({
      host: '127.0.0.1',
      script_name: '/tmt_test'
    })
    routes.oslc_user_url(1).should eq 'http://127.0.0.1/tmt_test/oslc/users/1'
  end

  it "should change protocol, host, port and script_name of URL" do
    routes = Oslc::Core::Routes.new({
      protocol: 'https',
      port: 3013,
      host: '127.0.0.1',
      script_name: '/tmt_test'
    })
    url = 'https://127.0.0.1:3013/tmt_test/oslc/automation/service-providers/1/plans/2'
    routes.oslc_automation_service_provider_plan_url(1, 2).should eq url
  end

end
