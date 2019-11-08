require 'spec_helper'

describe Oslc::Automation::Request::Resource do
  let(:user) { create(:user) }

  let(:project) do
    project = test_run.project
    project.add_member(user)
    project
  end

  let(:adapter) do
    create(:automation_adapter, project: project, user: user)
  end

  let(:test_run) do
    test_run = execution.test_run
    test_run.executor = user
    test_run.status = 2
    test_run.save(validate: false)
    test_run
  end

  let(:test_script) do
    execution.version
  end

  let(:test_case) do
    test_script.test_case
  end

  let(:execution) do
    create(:execution_for_passed, comment: 'Generated report', progress: 23)
  end

  def automation_request(oslc_properties=nil)
    ::Oslc::Automation::Request::Resource.new(execution, {machine: user, project: project, oslc_properties: oslc_properties})
  end

  def doc(parser)
    content = ''
    if parser == :rdf
      content = automation_request.to_rdf
    elsif parser == :xml
      content = automation_request.to_xml
    end
    Nokogiri::XML(content)
  end

  it "should show type" do
    doc(:rdf).xpath("//rdf:type").to_s.should eq('<rdf:type rdf:resource="http://open-services.net/ns/auto#AutomationRequest"/>')
    doc(:xml).xpath("//rdf:type").to_s.should eq('')
    doc(:xml).to_s.should include('AutomationRequest')
  end

  [:xml, :rdf].each do |format|
    describe "for '#{format.to_s.upcase}' format" do
      it "should connect with action" do
        doc(format).xpath("//rdf:RDF").size.should eq(1)
        doc(format).to_s.should include('AutomationRequest')
      end

      it "should show 'oslc:instanceShape' property" do
        doc(format).xpath("//oslc:instanceShape").to_s.should eq("<oslc:instanceShape rdf:resource=\"#{server_url('/oslc/automation/resource-shapes/request')}\"/>")
      end

      it "should show 'dcterms:identifier' property" do
        result = doc(format).xpath('//dcterms:identifier').first.text
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/requests/#{execution.id}")
      end

      it "should show 'state' property" do
        doc(format).xpath('//oslc_auto:state').to_s.should eq('<oslc_auto:state rdf:resource="http://open-services.net/ns/auto#new"/>')
      end

      it "should show 'dcterms:created' property" do
        time = Support::Oslc::Date.new(execution.created_at).iso8601
        doc(format).xpath('//dcterms:created').text.should eq time
      end

      it "should show 'dcterms:modified' property" do
        time = Support::Oslc::Date.new(execution.updated_at).iso8601
        doc(format).xpath("//dcterms:modified").text.should eq time
      end

      it "should show 'oslc_auto:executesAutomationPlan' property" do
        result = doc(format).xpath('//oslc_auto:executesAutomationPlan').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/plans/#{execution.id}")
      end

      it "should show 'oslc:serviceProvider' property" do
        result = doc(format).xpath('//oslc:serviceProvider').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}")
      end

      it "should show 'rqm_auto:progress' property" do
        doc(format).xpath('//rqm_auto:progress').text.should eq '23'
      end

      it "should show 'oslc_qm:executesTestScript' property" do
        result = doc(format).xpath('//oslc_qm:executesTestScript').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{test_script.id}")
      end

      it "should show 'rqm_auto:stateUrl' property" do
        result = doc(format).xpath('//rqm_auto:stateUrl').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/requests/#{test_script.id}?oslc.properties=oslc_auto%3Astate")
      end

      it "should show 'rqm_auto:executesOnAdapter' property" do
        ready(adapter)
        result = doc(format).xpath('//rqm_auto:executesOnAdapter').first.attributes['resource'].value
        result.should eq server_url("/oslc/automation/service-providers/#{project.id}/adapters/#{adapter.id}")
      end

      it "should show 'dcterms:creator' property" do
        result = doc(format).xpath('//dcterms:creator').first.attributes['resource'].value
        result.should eq server_url("/oslc/users/#{test_run.creator_id}")
      end

      it "should show 'rqm_auto:attachment' property" do
        result = doc(format).xpath('//rqm_auto:attachment').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{test_script.id}/download")
      end

      it "should show 'dcterms:title' property" do
        doc(format).xpath('//dcterms:title').text.should eq("Execute #{test_case.name}")
      end

      it "shows 'rqm_auto:taken' property" do
        doc(format).xpath('//rqm_auto:taken').text.should eq 'true'
      end
    end
  end

  it "shows 'inputParameter' property for 'rdf' format" do
    custom_field = create(:test_case_custom_field_for_text, name: 'fileName')
    test_case.custom_field_values.create(custom_field: custom_field, text_value: '/filename.seq')
    doc(:rdf).xpath('//oslc_auto:inputParameter/@rdf:nodeID').text.should eq "node1"
    doc = doc(:rdf).xpath("//rdf:Description[@rdf:nodeID=\"node1\"]")
    doc.xpath('//rdf:value').text.should eq '/filename.seq'
    doc.xpath('//oslc:name').text.should eq 'fileName'
    doc.xpath('//rdf:type').to_xml.should include '<rdf:type rdf:resource="http://open-services.net/ns/auto#ParameterInstance"/>'
  end

  it "shows 'inputParameter' property for 'xml' format" do
    custom_field = create(:test_case_custom_field_for_text, name: 'fileName')
    test_case.custom_field_values.create(custom_field: custom_field, text_value: '/filename.seq')
    doc(:rdf).xpath('//oslc_auto:inputParameter/@rdf:nodeID').text.should eq "node1"
    rdf = doc(:rdf).xpath("//oslc_auto:inputParameter")
    rdf.xpath('//rdf:value').text.should eq '/filename.seq'
    rdf.xpath('//oslc:name').text.should eq 'fileName'
  end

  it "shows 'inputParameter' property for 'rdf' format" do
    custom_field = create(:test_case_custom_field_for_text, name: 'fileName')
    test_case.custom_field_values.create(custom_field: custom_field, text_value: '/filename.seq')
    rdf = automation_request('oslc_auto:inputParameter').to_rdf
    rdf = Nokogiri::XML(rdf)
    rdf.xpath('//rdf:value').text.should eq('/filename.seq')
    rdf.xpath('//oslc:name').text.should eq('fileName')
    rdf.xpath('//oslc_auto:inputParameter').should have(1).item
    rdf.xpath('//rqm_auto:stateUrl').should have(0).items
  end

end
