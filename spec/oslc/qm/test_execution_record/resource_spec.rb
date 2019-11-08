require 'spec_helper'

describe Oslc::Qm::TestExecutionRecord::Resource do

  let(:oliver) { create(:user) }

  let(:john) { execution.test_run.creator }

  let(:project) do
    execution.project
  end

  let(:execution) do
    executor = create(:execution_for_passed)
    test_run = executor.test_run
    test_run.executor = oliver
    test_run.save(validate: false)
    executor
  end

  def resource oslc_properties=nil
    Oslc::Qm::TestExecutionRecord::Resource.new(execution, {
      project: project,
      oslc_properties: oslc_properties
    })
  end

  def doc(parser)
    content = ''
    if parser == :rdf
      content = resource.to_rdf
    elsif parser == :xml
      content = resource.to_xml
    end
    Nokogiri::XML(content)
  end

  it "should show type" do
    doc(:rdf).xpath("//rdf:type").to_s.should eq('<rdf:type rdf:resource="http://open-services.net/ns/qm#TestExecutionRecord"/>')
    doc(:xml).xpath("//rdf:type").to_s.should eq('')
    doc(:xml).to_s.should include('TestExecutionRecord')
  end

  [:xml, :rdf].each do |format|
    describe "for '#{format.to_s.upcase}' format" do
      it "should show 'dcterms:title' property" do
        title = "Execute #{execution.test_case.name}"
        doc(format).at_xpath('//dcterms:title').text.should eq title
      end

      it "should show 'dcterms:identifier' property" do
        url = server_url("/oslc/qm/service-providers/#{project.id}/test-execution-records/#{execution.id}")
        doc(format).at_xpath('//dcterms:identifier').text.should eq url
      end

      it "should show 'dcterms:creator' property" do
        url = server_url("/oslc/users/#{john.id}")
        result = doc(format).at_xpath('//dcterms:creator').attributes['resource'].value
        result.should eq url
      end

      it "should show 'dcterms:contributor' property when TestRun has assigned to executor" do
        url = server_url("/oslc/users/#{oliver.id}")
        result = doc(format).at_xpath('//dcterms:contributor').attributes['resource'].value
        result.should eq url
      end

      it "should show 'dcterms:contributor' property when TestRun hasn't assigned to executor" do
        test_run = execution.test_run
        test_run.update(executor: nil)
        test_run.reload.executor.should be nil
        doc(format).at_xpath('//dcterms:contributor').should be nil
      end

      it "should show 'dcterms:created' property" do
        date = Support::Oslc::Date.new(execution.created_at).iso8601
        doc(format).at_xpath('//dcterms:created').text.should eq date
      end

      it "should show 'dcterms:modified' property" do
        date = Support::Oslc::Date.new(execution.updated_at).iso8601
        doc(format).at_xpath('//dcterms:modified').text.should eq date
      end

      it "should show 'oslc:instanceShape' property" do
        url = server_url('/oslc/qm/resource-shapes/test-execution-record')
        result = doc(format).at_xpath('//oslc:instanceShape').attributes['resource'].value
        result.should eq url
      end

      it "should show 'oslc:serviceProvider' property" do
        url = server_url("/oslc/qm/service-providers/#{project.id}")
        result = doc(format).at_xpath('//oslc:serviceProvider').attributes['resource'].value
        result.should eq url
      end

      it "should show 'oslc_qm:runsTestCase' propery" do
        test_case = execution.test_case
        url = server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}")
        result = doc(format).at_xpath('//oslc_qm:runsTestCase').attributes['resource'].value
        result.should eq url
      end

      it "should show 'oslc_qm:reportsOnTestPlan' property" do
        test_run = execution.test_run
        url = server_url("/oslc/qm/service-providers/#{project.id}/test-plans/#{test_run.id}")
        result = doc(format).at_xpath('//oslc_qm:reportsOnTestPlan').attributes['resource'].value
        result.should eq url
      end
    end
  end

end
