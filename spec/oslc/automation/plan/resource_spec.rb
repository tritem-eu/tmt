require 'spec_helper'

describe Oslc::Automation::Plan::Resource do
  let(:user) { test_run.creator }

  let(:project) do
    project = test_run.project
    project.add_member(user)
    project
  end

  let(:test_run) do
    execution.test_run
  end

  let(:test_case) do
    execution.test_case
  end

  let(:execution) do
    create(:execution_for_passed, comment: 'Generated report')
  end

  def doc(parser)
    content = ''
    plan = ::Oslc::Automation::Plan::Resource.new(execution.reload)
    if parser == :xml
      content = plan.to_xml
    elsif parser == :rdf
      content = plan.to_rdf
    end
    Nokogiri::XML(content)
  end

  [:xml, :rdf].each do |format|
    describe "for '#{format.to_s.upcase}' format" do
      before do
        test_case.update(name: 'Open door')
      end

      it "should connect with action" do
        doc(format).xpath("//rdf:RDF").size.should eq(1)
      end

      it "should show 'rdf:about' property" do
        result = doc(format).xpath("//*[@rdf:about]").first.attributes['about'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
      end

      it "should show 'rdf:type' property" do
        doc(format).to_xml.should include("AutomationPlan")
      end

      it "should show 'dcterms:title' property" do
        doc(format).xpath('//dcterms:title').text.should eq('Open door')
      end

      it "should show 'dcterms:created' property" do
        time = Support::Oslc::Date.new(execution.created_at).iso8601
        doc(format).xpath('//dcterms:created').text.should eq time
      end

      it "should show 'oslc:instanceShape' property" do
        result = doc(format).xpath('//oslc:instanceShape').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/resource-shapes/plan")
      end

      it "should show 'oslc_qm:runsTestCase' property" do
        result = doc(format).xpath('//oslc_qm:runsTestCase').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}")
      end

      it "should show 'oslc:serviceProvider' property" do
        result = doc(format).xpath('//oslc:serviceProvider').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}")
      end

      it "should show 'dcterms:identifier' property" do
        plan_url = server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
        result = doc(format).xpath('//dcterms:identifier').text
        result.should eq plan_url
      end

      it "should show 'dcterms:modified' property" do
        time = Support::Oslc::Date.new(execution.updated_at).iso8601
        doc(format).xpath("//dcterms:modified").text.should eq time
      end

      it "should show 'dcterms:creator' property" do
        result = doc(format).xpath("//dcterms:creator")[0].attributes['resource'].value
        result.should eq server_url("/oslc/users/#{test_run.creator_id}")
      end

      it 'shows "contributor" property' do
        ready(project)
        result = doc(format).xpath("//dcterms:contributor")[0].attributes['resource'].value
        result.should eq server_url("/oslc/users/#{user.id}")
      end

      it "shouldn't show 'dcterms:contributor' property" do
        test_run.executor_id = nil
        test_run.save(validate: false)
        doc(format).xpath("//dcterms:contributor").should be_empty
      end
    end
  end
end
