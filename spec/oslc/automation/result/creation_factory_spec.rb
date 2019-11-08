require 'spec_helper'

describe Oslc::Automation::Result::CreationFactory do
  include Support::Oslc

  let(:execution) do
    execution = create(:execution, progress: 13, status: nil)
    execution.set_executing
    execution
  end

  let(:project) do
    project = create(:project)
    project.add_member(create(:user))
    project
  end

  def build_rdf_content(selectors=[])
    Tmt::XML::RDFXML.new(xmlns: {
      rdf: :rdf,
      rqm_auto: :rqm_auto,
      oslc_auto: :oslc_auto,
      dcterms: :dcterms
    }, xml: {lang: :en}) do |xml|
      if selectors.include?(:type)
        xml.add "rdf:type", rdf: {resource: 'http://open-services.net/ns/auto#AutomationResult'}
      end

      xml.add('oslc_auto:producedByAutomationRequest', rdf: {resource: "http://example.com/oslc/automation_request/#{execution.id}"})

      xml.add("oslc_auto:contribution") do
        "<![CDATA[<h1>Report of execution</h1> PASSED]]>"
      end

      xml.add("dcterms:title") do
        "Automation Result"
      end

      xml.add "oslc_auto:state", rdf: {resource: 'http://open-services.net/ns/auto#complete'}

      xml.add "oslc_auto:verdict", rdf: {resource: 'http://open-services.net/ns/auto#failed'}

    end.to_xml
  end

  def creation_factory_for_elements(selectors=[])
    rdf_content = build_rdf_content(selectors)
    creation_factory = Oslc::Automation::Result::CreationFactory.new(rdf_content, project: project)
    creation_factory.save
    execution.reload
    creation_factory
  end

  context "when RDF content is correct" do

    it 'creates new result' do
      execution.status.should equal(execution.class::STATUS_EXECUTING)
      creation_factory_for_elements([:type])
      execution.reload
      execution.status.should eq(execution.class::STATUS_FAILED.to_s)
      execution.comment.should eq('Automation Result')
      execution.attached_files.size.should eq(1)
      attached_file = execution.attached_files[0][:compressed_file]
      attached_file.decompress.should eq("<h1>Report of execution</h1> PASSED")
    end

    it "does not create new result when exist one" do
      execution.status.should equal(execution.class::STATUS_EXECUTING)
      creation_factory_for_elements([:type])
      execution.reload
      last_updated_at = execution.updated_at.to_f
      creation_factory_for_elements([:type])
      execution.reload
      execution.updated_at.to_f.should eq(last_updated_at)
      execution.status.should eq(execution.class::STATUS_FAILED.to_s)
      execution.comment.should eq('Automation Result')
      execution.attached_files.size.should eq(1)
      attached_file = execution.attached_files[0][:compressed_file]
      attached_file.decompress.should eq("<h1>Report of execution</h1> PASSED")
    end

  end

  context "when RDF content is incorrect" do
    it 'creates new result' do
      execution.status.should equal(execution.class::STATUS_EXECUTING)
      creation_factory = creation_factory_for_elements()
      execution.reload
      execution.status.should eq(execution.class::STATUS_NONE.to_s)
      creation_factory.response.should include("<oslc:message>Type of content is incorrect</oslc:message>")
    end
  end

end
