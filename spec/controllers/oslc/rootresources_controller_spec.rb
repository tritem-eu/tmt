require 'spec_helper'

describe Oslc::RootservicesController do
  extend CanCanHelper

  let(:xml) { Nokogiri::XML(response.body) }

  [:rdf, :xml, :html].each do |format|
    describe "GET show for format: #{format}" do
      it "should collect projects where current_user is a member" do
        get :show, format: format
        xml.at_xpath('//oslc_qm:qmServiceProviders').attributes['resource'].value.should eq server_url("/oslc/qm/service-providers")
        xml.at_xpath('//oslc_auto:autoServiceProviders').attributes['resource'].value.should eq server_url("/oslc/automation/service-providers")
      end
    end
  end

end
