require 'spec_helper'
module RspecDummy
  class OslcCoreResourceShape < ::Oslc::Core::ResourceShape
    define_namespaces do
      {
        dcterms: :dcterms,
        rdf: :rdf,
        oslc: :oslc,
        oslc_qm: :oslc_qm,
        oslc_auto: :oslc_auto
      }
    end

    after_initialize do
      request_uri do
        server_url('/oslc/service-provider/example')
      end

      title_of_shape 'Dummy Resource Shape'

      resource_type 'http://jazz.net/ns/auto/rqm#AutomationPlan'
    end

    define_properties do
      [
        [:property_definition,            :occurs,             :read_only,  :value_type,        :representation,  :range,                  :value_shape,  :hidden, :description],
        ["dcterms:title",                 "oslc:Exactly-one",  "true",      "xmls:string",      nil,              nil,                     nil,           "false", "Title."],
      ]
    end
  end
end

describe Oslc::Core::ResourceShape do
  let(:project) { create(:project) }

  let(:machine) do
    user = create(:user)
    project.add_member(user)
    user
  end

  def doc(format)
    content = ''
    resource_shape = RspecDummy::OslcCoreResourceShape.new()
    if format == :rdf
      content = resource_shape.to_rdf
    elsif format == :xml
      content = resource_shape.to_xml
    end
    Nokogiri::XML(content)
  end

  it "should show 'rdf:Description' class for RDF format" do
    result = doc(:rdf).at_xpath("//rdf:Description[@rdf:about]").attributes['about'].text
    result.should eq server_url('/oslc/service-provider/example')
    result = doc(:rdf).at_xpath('//rdf:Description/oslc:property').attributes['nodeID'].value
    result = doc(:rdf).at_xpath('//rdf:Description[@rdf:nodeID]//oslc:name').text
    result.should eq 'title'
  end

  it "should show 'rdf:Description' class for XML format" do
    result = doc(:xml).at_xpath('//oslc:ResourceShape').attributes['about'].text
    result.should eq server_url('/oslc/service-provider/example')
    result = doc(:xml).at_xpath('//oslc:ResourceShape//oslc:name').text
    result.should eq 'title'
  end

end
