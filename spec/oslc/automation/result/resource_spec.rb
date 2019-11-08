require 'spec_helper'

describe Oslc::Automation::Adapter::Resource do
  include Support::Oslc

  let(:user) { test_run.executor }

  let(:project) do
    test_run.project
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

  def doc(format)
    ready(project, execution)
    content = ''
    result = ::Oslc::Automation::Result::Resource.new(execution)
    if format == :xml
      content = result.to_xml
    elsif format == :rdf
      content = result.to_rdf
    end
    Nokogiri::XML(content)
  end

  it "should show type" do
    doc(:rdf).xpath("//rdf:type").to_s.should eq('<rdf:type rdf:resource="http://open-services.net/ns/auto#AutomationResult"/>')
    doc(:xml).xpath("//rdf:type").to_s.should eq('')
    doc(:rdf).to_s.should include('AutomationResult')
  end

  [:xml, :rdf].each do |format|
    describe "for '#{format.to_s.upcase}' format" do
      it "should show 'rdf:about' property" do
        result = doc(format).xpath("//*[@rdf:about]").first.attributes['about'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/results/#{execution.id}")
      end

      it "should show 'rdf:RDF' class" do
        doc(format).xpath("//rdf:RDF").should have(1).item
      end

      it "should show 'dcterms:title' property" do
        doc(format).xpath('//dcterms:title').text.should eq('Generated report')
      end

      it "should show 'dcterms:created' property" do
        time = Support::Oslc::Date.new(execution.created_at).iso8601
        doc(format).xpath('//dcterms:created').text.should eq time
      end

      it "should show 'oslc:instanceShape' property" do
        doc(format).xpath("//oslc:instanceShape").to_s.should eq("<oslc:instanceShape rdf:resource=\"#{server_url('/oslc/automation/resource-shapes/result')}\"/>")
      end

      it "should show 'oslc_auto:state' property" do
        doc(format).xpath('//oslc_auto:state').to_s.should eq('<oslc_auto:state rdf:resource="http://open-services.net/ns/auto#complete"/>')
      end

      it "should show 'oslc_auto:verdict' property" do
        doc(format).xpath('//oslc_auto:verdict').to_s.should eq('<oslc_auto:verdict rdf:resource="http://open-services.net/ns/auto#passed"/>')
      end

      it "should show 'oslc_auto:producedByAutomationRequest' property" do
        result = doc(format).xpath('//oslc_auto:producedByAutomationRequest').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/requests/#{execution.id}")
      end

      it "should show 'oslc_qm:reportsOnTestCase' property" do
        result = doc(format).xpath('//oslc_qm:reportsOnTestCase').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}")
      end

      it "should show 'oslc:serviceProvider' property" do
        result = doc(format).xpath('//oslc:serviceProvider').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}")
      end

      it "should show 'dcterms:identifier' property" do
        result = doc(format).xpath('//dcterms:identifier').text
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/results/#{execution.id}")
      end

      it "should show 'dcterms:creator' property" do
        result = doc(format).xpath('//dcterms:creator').first.attributes['resource'].text
        result.should eq server_url("/oslc/users/#{user.id}")
      end

      it "should show 'dcterms:contributor' property" do
        result = doc(format).xpath('//dcterms:contributor').first.attributes['resource'].text
        result.should eq server_url("/oslc/users/#{user.id}")
      end

      it "should show 'oslc_auto:initialParameter' property" do
        custom_field_value = create(:test_case_custom_field_value,
          test_case: test_case,
          text_value: 'Example text'
        )
        doc(format).xpath('//rdf:value').text.should eq 'Example text'
        doc(format).xpath('//oslc:name').text.should eq 'Description'
      end

      it "should show 'dcterms:modified' property" do
        time = Support::Oslc::Date.new(execution.updated_at).iso8601
        doc(format).xpath("//dcterms:modified").text.should eq time
      end

      it "should show 'oslc_auto:reportsOnAutomationPlan' property" do
        result = doc(format).xpath('//oslc_auto:reportsOnAutomationPlan').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
      end

      it "should show 'rqm_auto:executedOnMachine' property" do
        result = doc(format).xpath('//rqm_auto:executedOnMachine')[0].attributes['resource'].value
        result.should eq server_url("/oslc/users/#{user.id}")
      end

      it "shouldn't show 'rqm_auto:executedOnMachine' property when TestRun objec hasn't defined an executor" do
        ready(project)
        test_run.executor_id = nil
        test_run.save(validate: false)
        test_run.executor_id.should be_nil
        doc(format).xpath('//rqm_auto:executedOnMachine').should be_empty
      end
    end
  end
end
