require 'spec_helper'

describe Oslc::Qm::TestResult::Resource do
  include Support::Oslc

  let(:user) { create(:user) }

  let(:project) do
    project = test_case.project
    project.add_member(user)
    project
  end

  let(:test_run) do
    test_run = execution.test_run
    test_run.executor = user
    test_run.save(validate: false)
  end

  let(:test_case) do
    execution.test_case
  end

  let(:execution) do
    create(:execution_for_passed, comment: 'Generated report')
  end

  let(:test_script) do
    execution.version
  end

  def doc(format)
    ready(project, execution)
    content = ''
    result = ::Oslc::Qm::TestResult::Resource.new(execution)
    if format == :xml
      content = result.to_xml
    elsif format == :rdf
      content = result.to_rdf
    end
    Nokogiri::XML(content)
  end

  before do
    ready(test_run)
  end

  it "should show type" do
    result = doc(:rdf).at_xpath("//rdf:type").attributes['resource'].value
    result.should eq 'http://open-services.net/ns/qm#TestResult'
    doc(:xml).xpath("//rdf:type").to_s.should eq('')
    doc(:rdf).to_s.should include('TestResult')
  end

  [:xml, :rdf].each do |format|
    describe "for '#{format.to_s.upcase}' format" do
      it "should show 'rdf:about' property" do
        result = doc(format).xpath("//*[@rdf:about]").first.attributes['about'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-results/#{execution.id}")
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
        doc(format).xpath("//oslc:instanceShape").to_s.should eq("<oslc:instanceShape rdf:resource=\"#{server_url('/oslc/qm/resource-shapes/test-result')}\"/>")
      end

      it "should show 'oslc_qm:status' property" do
        result = doc(format).at_xpath('//oslc_qm:status').attributes['resource'].text
        result.should eq 'http://open-services.net/ns/auto#complete'
      end

      it "should show 'oslc_qm:producedByTestExecutionRecord' property" do
        result = doc(format).xpath('//oslc_qm:producedByTestExecutionRecord').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-execution-records/#{execution.id}")
      end

      it "should show 'oslc_qm:executesTestScript' property" do
        result = doc(format).xpath('//oslc_qm:executesTestScript').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{test_script.id}")
      end

      it "should show 'oslc_qm:reportsOnTestCase' property" do
        result = doc(format).xpath('//oslc_qm:reportsOnTestCase').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}")
      end

      it "should show 'oslc:serviceProvider' property" do
        result = doc(format).xpath('//oslc:serviceProvider').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}")
      end

      it "should show 'dcterms:identifier' property" do
        result = doc(format).xpath('//dcterms:identifier').text
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-results/#{execution.id}")
      end

      it "should show 'dcterms:modified' property" do
        time = Support::Oslc::Date.new(execution.updated_at).iso8601
        doc(format).xpath("//dcterms:modified").text.should eq time
      end

      it "should show 'oslc_qm:reportsOnTestPlan' property" do
        result = doc(format).xpath('//oslc_qm:reportsOnTestPlan').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-plans/#{execution.id}")
      end

    end
  end
end
