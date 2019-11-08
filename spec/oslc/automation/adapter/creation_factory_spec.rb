require 'spec_helper'

describe Oslc::Automation::Adapter::CreationFactory do
  include Support::Oslc

  let(:machine) do
    create(:user)
  end

  let(:project) do
    project = create(:project)
    project.add_member(machine)
    project
  end

  def build_rdf_content(selectors=[])
    Tmt::XML::RDFXML.new(xmlns: {
      rdf: :rdf,
      rqm_auto: :rqm_auto,
      dcterms: :dcterms
    }, xml: {lang: :en}) do |xml|
      if selectors.include?(:type)
        xml.add "rdf:type", rdf: {resource: 'http://jazz.net/ns/auto/rqm#AutomationAdapter'}
      end

      xml.add("dcterms:description") do
        "Description of Adapter"
      end

      xml.add "dcterms:title" do
        "Title of Adapter"
      end

      if selectors.include?(:polling_interval)
        xml.add "rqm_auto:pollingInterval" do
          "7"
        end
      end

      if selectors.include?(:adapter_type)
        xml.add "dcterms:type" do
          Tmt.config.value(:oslc, :execution_adapter_type, :id)
        end
      end

    end.to_xml
  end

  def creation_factory_for_elements(selectors=[])
    rdf_content = build_rdf_content(selectors)
    creation_factory = Oslc::Automation::Adapter::CreationFactory.new(rdf_content, project: project, machine_id: machine.id)
    creation_factory.save
    creation_factory
  end

  context "when RDF content is correct" do

    it 'creates new result' do
      Tmt::AutomationAdapter.any?.should be false
      creation_factory_for_elements([:type, :adapter_type, :polling_interval])
      Tmt::AutomationAdapter.any?.should be true
      adapter = Tmt::AutomationAdapter.first
      adapter.name.should eq 'Title of Adapter'
      adapter.description.should eq 'Description of Adapter'
      adapter.polling_interval.should eq 7
      adapter.adapter_type.should eq Tmt.config[:oslc][:execution_adapter_type][:id]
      adapter.user_id.should eq machine.id
      adapter.project_id.should eq project.id
    end
  end

  context "when RDF content is incorrect" do

    it 'does not create new result when RDF does not have defined type' do
      Tmt::AutomationAdapter.any?.should be false
      creation_factory_for_elements()
      Tmt::AutomationAdapter.any?.should be false
    end

    it 'does not create new result when RDF does not have defined adapter type' do
      Tmt::AutomationAdapter.any?.should be false
      creation_factory = creation_factory_for_elements([:type, :polling_interval])
      Tmt::AutomationAdapter.any?.should be false
      creation_factory.response.should include("<oslc:message>An object of type http://jazz.net/ns/auto/rqm#AutomationAdapter cannot be created. Adapter type does not exist</oslc:message>")
    end

    it 'does not create new result when RDF does not have defined polling_interval' do
      Tmt::AutomationAdapter.any?.should be false
      creation_factory = creation_factory_for_elements([:type, :adapter_type])
      Tmt::AutomationAdapter.any?.should be false
      creation_factory.response.should include("<oslc:message>'//rqm_auto:pollingInterval' selector cannot be parsed</oslc:message>")
    end

  end
end
