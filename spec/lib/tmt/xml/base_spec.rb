require 'spec_helper'

describe Tmt::XML::Base do
  describe ".vocabulary_type_url when" do
    it "vocabulary type exist in list" do
      Tmt::XML::Base.vocabulary_type_url('oslc:Resource').should eq("http://open-services.net/ns/core#Resource")
    end

    it "vocabulary type doesn't exist in list" do
      expect do
        Tmt::XML::Base.vocabulary_type_url("dummy:error")
      end.to raise_error(RuntimeError, "Didn't define key 'dummy'")
    end

    it "vocabulary_type is url" do
      Tmt::XML::Base.vocabulary_type_url("http://open-services.net/ns/core#Resource").should eq("http://open-services.net/ns/core#Resource")
    end
  end

  describe "User starts from class" do
    subject { Tmt::XML::Base.new("oslc:Property") }

    it "#to_rdf" do
      subject.to_xml.should eq %Q{<oslc:Property />}
    end

    it "#to_rdf with attribute 'about'" do
      Tmt::XML::Base.new("oslc:Property", rdf: {about: "http://example.com"}) .to_xml.should eq %Q{<oslc:Property rdf:about="http://example.com" />}
    end

    it "#add_property" do
      subject.add("foaf:title") { "Title" }
      subject.to_xml.should match %Q{<oslc:Property><foaf:title>Title</foaf:title></oslc:Property>}
    end

    it "#add_class" do
      subject.add("foaf:Title") do |title|
      end
      subject.to_xml.should match %Q{<oslc:Property><foaf:Title /></oslc:Property>}
    end
  end

  describe "User adds property into class" do
    subject { Tmt::XML::Base.new("oslc:title") { "Title" } }

    let(:property) { Tmt::XML::Base.new("oslc:title") }

    it "#to_rdf" do
      subject.to_xml.should eq %Q{<oslc:title>Title</oslc:title>}
    end

    it "#add_class" do
      property.add("foaf:Title", rdf: {ID: "link32"}) { |title| }
      property.to_xml.should match %Q{<oslc:title><foaf:Title rdf:ID="link32" /></oslc:title>}
    end

    it "#add" do
      property.add("foaf:Title", rdf: {ID: "link32"}) { }
      property.to_xml.should match %Q{<oslc:title><foaf:Title rdf:ID="link32" /></oslc:title>}
    end

    it "can ending object with quote '/' when it hasn't got any value" do
      property.to_xml.should eq %Q{<oslc:title />}
    end

  end
end
