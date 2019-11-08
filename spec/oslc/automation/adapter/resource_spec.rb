require 'spec_helper'

describe Oslc::Automation::Adapter::Resource do
  include Support::Oslc

  let(:user) { create(:user) }

  let(:machine) { create(:machine, user: user) }

  let(:project) do
    project = create(:project)
    project.add_member(user)
    project
  end

  let(:automation_adapter) do
    create(:automation_adapter,
      description: 'Description 05.11.2014 09:53',
      name: "Adapter 05.11.2014 09:30",
      polling_interval: 23,
      project: project,
      user: user
    )
  end

  def doc(parser)
    content = ''
    plan = ::Oslc::Automation::Adapter::Resource.new(automation_adapter, machine: user)
    if parser == :xml
      content = plan.to_xml
    elsif parser == :rdf
      content = plan.to_rdf
    end
    Nokogiri::XML(content)
  end

  [:rdf, :xml].each do |format|
    describe "for '#{format}' and user is machine" do
      before do
        ready(user, machine)
      end

      it "should connect with action" do
        doc(format).xpath("//rdf:RDF").size.should eq(1)
      end

      it "should show 'rdf:about' property" do
        result = doc(format).xpath("//*[@rdf:about]").first.attributes['about'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{automation_adapter.id}")
      end

      it "should show type" do
        doc(format).to_xml.should include("AutomationAdapter")
      end

      it "should show 'rqm_auto:ipAddress' property" do
        doc(format).xpath("//rqm_auto:ipAddress").text.should eq(machine.ip_address)
      end

      it "should show serviceProvider" do
        provider_url = server_url("/oslc/automation/service-providers/#{project.id}")
        doc(format).xpath("//oslc:serviceProvider").to_s.should eq("<oslc:serviceProvider rdf:resource=\"#{provider_url}\"/>")
      end

      it "should show creator" do
        user_url = server_url("/oslc/users/#{automation_adapter.creator.id}")
        doc(format).xpath("//dcterms:creator").to_s.should eq("<dcterms:creator rdf:resource=\"#{user_url}\"/>")
      end

      it "should show 'rqm_auto:workAvailable' property" do
        doc(format).xpath("//rqm_auto:workAvailable").text.should eq "false"
      end

      it "should show 'dcterms:title' property" do
        doc(format).xpath("//dcterms:title").text.should eq(automation_adapter.name)
      end

      it "should show 'rqm_auto:assignedWorkUrl' property" do
        doc(format).xpath("//rqm_auto:assignedWorkUrl").to_s.should include("rqm_auto%3Ataken%3Dfalse")
      end

      it "should show 'dcterms:type' property" do
        doc(format).xpath("//dcterms:type").text.should eq(automation_adapter.adapter_type)
      end

      it "should show pollingInterval" do
        doc(format).xpath("//rqm_auto:pollingInterval").text.should eq('23')
      end

      it "should show modified" do
        time = Support::Oslc::Date.new(automation_adapter.updated_at).iso8601
        doc(format).xpath("//dcterms:modified").text.should eq time
      end

      it "should show 'rqm_auto:workAvailableUrl' property" do
        url = server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{automation_adapter.id}?oslc.properties=rqm_auto%3AworkAvailable")
        doc(format).xpath("//rqm_auto:workAvailableUrl").to_s.should include url
      end

      it "should show instanceShape" do
        doc(format).xpath("//oslc:instanceShape").to_s.should eq "<oslc:instanceShape rdf:resource=\"#{server_url}/oslc/automation/resource-shapes/adapter\"/>"
      end

      it "should show 'rqm_auto:runsOnMachine' property" do
        user_url = server_url("/oslc/users/#{automation_adapter.user_id}")
        result = doc(format).at_xpath("//rqm_auto:runsOnMachine").attributes['resource'].text
        result.should eq user_url
      end

      it "should show 'rqm_auto:fullyQualifiedDomainName' property" do
        doc(format).xpath("//rqm_auto:fullyQualifiedDomainName").text.should eq(machine.fully_qualified_domain_name)
      end

      it "should show description" do
        doc(format).xpath("//dcterms:description").text.should eq('Description 05.11.2014 09:53')
      end

      it "should show 'rqm_auto:macAddress' property" do
        doc(format).xpath("//rqm_auto:macAddress").text.should eq(machine.mac_address)
      end

      it "should show description" do
        automation_url = server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{automation_adapter.id}")
        doc(format).xpath("//dcterms:identifier").text.should eq automation_url
      end

      it "should show 'rqm_auto:hostname' property" do
        doc(format).xpath("//rqm_auto:hostname").text.should eq(machine.hostname)
      end
    end

    describe "for '#{format}' format and user isn't machine" do
      before do
        ready(user)
        Tmt::Machine.delete_all
      end

      it "should not show 'rqm_auto:macAddress' property" do
        doc(format).xpath("//rdf:RDF").size.should eq(1)
        doc(format).xpath("//rqm_auto:macAddress").should have(0).items
      end
    end
  end
end
