module Support
  # This module should be used anywhere where we want testing 'Resource Shape'
  # How to use
  #   include Support::Oslc

  #  it_should_behave_like "set of OSLC resource shapes" do
  #    let(:resource_shape) do
  #      ::Oslc::Automation::Request::ResourceShape.new(DummySpecController.new())
  #    end

  #    let(:resource_shape_url) do
  #      "http://example.com:3001/prefix/oslc/automation/resource-shapes"
  #    end
  #  end
  module Oslc
    def get(function_name)
      eval(function_name.to_s)
    end

    shared_examples_for "set of OSLC resource shapes" do
      let(:xml) do
        Nokogiri::XML(resource_shape.to_xml)
      end

      let(:rdf) do
        Nokogiri::XML(resource_shape.to_rdf)
      end

      it "should have mani 'rdf:RDF' property" do
        xml.xpath("//rdf:RDF").size.should eq(1)
      end

      it "should show service provider url in RDF format" do
        url = rdf.xpath('//rdf:Description[@rdf:about]')[0].attributes['about'].text()
        url.should eq(resource_shape_url)
      end

      it "should show service provider url in XML format" do
        url = xml.xpath('//oslc:ResourceShape[@rdf:about]')[0].attributes['about'].text()
        url.should eq(resource_shape_url)
      end

      it "should have oslc:name selector" do
        xml.xpath('//oslc:name').should_not be_empty
        rdf.xpath('//oslc:name').should_not be_empty
      end

      it "should have oslc:occurs selector" do
        xml.xpath('//oslc:occurs').should_not be_empty
        rdf.xpath('//oslc:occurs').should_not be_empty
      end

      it "should have oslc:readOnly selector" do
        xml.xpath('//oslc:readOnly').should_not be_empty
        rdf.xpath('//oslc:readOnly').should_not be_empty
      end

      it "should have oslc:valueType selector" do
        xml.xpath('//oslc:valueType').should_not be_empty
        rdf.xpath('//oslc:valueType').should_not be_empty
      end

      it "should have oslc:representation selector" do
        xml.xpath('//oslc:representation').should_not be_empty
        rdf.xpath('//oslc:representation').should_not be_empty
      end

      it "should have dcterms:description selector" do
        xml.xpath('//dcterms:description').should_not be_empty
        rdf.xpath('//dcterms:description').should_not be_empty
      end

      it "should have dcterms:title selector" do
        xml.xpath('//dcterms:title').should_not be_empty
        rdf.xpath('//dcterms:title').should_not be_empty
      end

      it "should have oslc:propertyDefinition selector" do
        xml.xpath('//oslc:propertyDefinition').should_not be_empty
        rdf.xpath('//oslc:propertyDefinition').should_not be_empty
      end

      it "should have oslc:hidden selector" do
        xml.xpath('//oslc:hidden').should_not be_empty
        rdf.xpath('//oslc:hidden').should_not be_empty
      end

      it "should have oslc:isMemberProperty selector" do
        xml.xpath('//oslc:isMemberProperty').should_not be_empty
        rdf.xpath('//oslc:isMemberProperty').should_not be_empty
      end

    end

    # Return list all 'attr_name' attributes which are in 'selector'
    # Example:
    #   doc = Nokogiri.parse(content)
    #   oslc_attributes_from(doc, '//rdf:Description//rdf:type', 'resource')
    def oslc_attributes_from(nokogiri, selector, attr_name)
      result  = []
      nokogiri.xpath(selector).each do |item|
        print attr_name
        result << item.attributes[attr_name].text
      end
      result
    rescue
      []
    end
  end
end
