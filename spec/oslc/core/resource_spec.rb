require 'spec_helper'
module RspecDummy
  class OslcCoreResource < ::Oslc::Core::Resource
      define_namespaces do
        {
          dcterms: :dcterms,
          rdf: :rdf,
          oslc: :oslc,
          oslc_qm: :oslc_qm,
          oslc_auto: :oslc_auto,
          rqm_auto: :rqm_auto,
          rqm_qm: :rqm_qm
        }
      end

      define_property "rqm_auto:progress" do
        long_to_define(13)
      end

      define_property "dcterms:identifier" do
        string_to_define(123)
      end

      def after_initialize
        define_resource_type 'oslc_auto:AutomationRequest'

        define_object_url do
          'http://example.com'
        end

        {
          'fileName' => 'C:\example.seq',
          'color'    => 'blue'
        }.each do |name, value|
          define_sub_selector @selectors, "oslc_auto:inputParameter" do |handler|
            define_sub_selector handler, "oslc_auto:ParameterInstance" do |handler|
              define_sub_selector(handler, "rdf:value") do |handler|
                string_to_define value
              end
              define_sub_selector(handler, "oslc:name") do |handler|
                string_to_define name
              end
            end
          end
        end
      end
  end
end

describe Oslc::Core::Resource do
  include Support::Oslc
  let(:project) { create(:project) }

  let(:machine) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:object) do
    object = 'object'
    def object.id
      123
    end
    object
  end

  def xml(oslc_property=nil)
    content = RspecDummy::OslcCoreResource.new(object, {oslc_properties: oslc_property}).to_xml
    Nokogiri::XML(content)
  end

  def rdf(oslc_property=nil)
    content = RspecDummy::OslcCoreResource.new(object, {oslc_properties: oslc_property}).to_rdf
    Nokogiri::XML(content)
  end

  it "should connect with action" do
    xml.xpath("//rdf:RDF").size.should eq(1)
    rdf.xpath("//rdf:RDF").size.should eq(1)
  end

  it "should show type" do
    rdf.xpath("//rdf:type").to_s.should include('<rdf:type rdf:resource="http://open-services.net/ns/auto#AutomationRequest"/>')
    rdf.xpath("//rdf:type").to_s.should include('<rdf:type rdf:resource="http://open-services.net/ns/auto#ParameterInstance"/>')
    xml.xpath("//rdf:type").to_s.should eq('')
  end

  it "should show progress" do
    xml.xpath("//rqm_auto:progress").text.should eq('13')
    rdf.xpath("//rqm_auto:progress").text.should eq('13')
  end

  it "shows identifier" do
    rdf.xpath("//dcterms:identifier").text.should eq('123')
    xml.xpath("//dcterms:identifier").text.should eq('123')
  end

  it "shows only progress when 'oslc.properties' is used" do
    rdf('rqm_auto:progress').xpath("//rqm_auto:progress").text.should eq('13')
    rdf('rqm_auto:progress').xpath("//dcterms:identifier").should have(0).items
    xml('rqm_auto:progress').xpath("//rqm_auto:progress").text.should eq('13')
    xml('rqm_auto:progress').xpath("//dcterms:identifier").should have(0).items
  end

  it "shows only inputParameter when 'oslc.properties' is used" do
    rdf('oslc_auto:inputParameter').xpath("//oslc_auto:inputParameter").should have(2).items
    #rdf('oslc_auto:inputParameter').xpath("//rdf:Description/@rdf:nodeID").should have(2).items
    rdf('oslc_auto:inputParameter').xpath("//dcterms:identifier").should have(0).items
    xml('oslc_auto:inputParameter').xpath("//oslc_auto:inputParameter").should have(2).items
    xml('oslc_auto:inputParameter').xpath("//dcterms:identifier").should have(0).items
  end

  it "should show identifier2" do
    main_section = rdf.xpath('//rdf:Description[@rdf:about="http://example.com"]')[0]
    main_section.should_not be_nil
    main_section = main_section.to_xml
    main_section.should include('<oslc_auto:inputParameter rdf:nodeID="node1"/>')
    main_section.should include('<oslc_auto:inputParameter rdf:nodeID="node2"/>')

    input_parameter = rdf.xpath("//rdf:Description[@rdf:nodeID='node1']")[0]
    input_parameter.should_not be_nil
    input_parameter = input_parameter.to_xml
    input_parameter.should include('<rdf:type rdf:resource="http://open-services.net/ns/auto#ParameterInstance"/>')
    input_parameter.should include('<rdf:value rdf:datatype="http://www.w3.org/2001/XMLSchema#string">C:\\example.seq</rdf:value>')
    input_parameter.should include('<oslc:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string">fileName</oslc:name>')
    xml.xpath("//oslc_auto:inputParameter").to_xml.should include('<oslc_auto:ParameterInstance>')
  end

end
