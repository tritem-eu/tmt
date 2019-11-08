require 'spec_helper'

describe Tmt::XML::RDFXML, type: :lib do

  subject { Tmt::XML::RDFXML }

  it "#to_rdf" do
    subject.new.to_xml.should eq pretty_xml(%Q{<?xml version="1.0" encoding="utf-8"?><rdf:RDF />})
  end

  it "should set language" do
    subject.new(xml: {lang: :en}).to_xml.should eq pretty_xml(%Q{<rdf:RDF xml:lang="en" />})
  end

  it "should set language" do
    subject.new(xml: {lang: :pl}).to_xml.should eq pretty_xml(%Q{<rdf:RDF xml:lang="pl" />})
  end

  it "should add property" do
    subject.new do |rdfxml|
      rdfxml.add("foaf:title") { "Title" }
    end.to_xml.should eq pretty_xml(%Q{<rdf:RDF><foaf:title>Title</foaf:title></rdf:RDF>})
  end

  it "should add class" do
    subject.new do |rdfxml|
      rdfxml.add("oslc:Property") do |property|
      end
    end.to_xml.should eq pretty_xml(%Q{<rdf:RDF><oslc:Property /></rdf:RDF>})
  end

  it "complex example" do
    Tmt::XML::RDFXML.new(xmlns: {dcterms: "http://purl.org/dc/terms/"}) do |rdfxml|
      rdfxml.add("oslc:property") do |property|
        property.add("oslc:Property") do |class_property|
          class_property.add("oslc:value") { "Value" }
        end
      end

      rdfxml.add("rdfs:member") {"example"}

      rdfxml.add("oslc:Comment") do |comment|
        comment.add("oslc:title") {"flower"}
        comment.add("foaf:Person") do |person|
          person.add("foaf:name") { "William B. Bird" }
          person.add("foaf:yead") { "1953" }
        end
      end
    end.to_xml.should eq pretty_xml(%Q{<?xml version=\"1.0\" encoding=\"utf-8\"?><rdf:RDF xmlns:dcterms=\"http://purl.org/dc/terms/\"><oslc:property><oslc:Property><oslc:value>Value</oslc:value></oslc:Property></oslc:property><rdfs:member>example</rdfs:member><oslc:Comment><oslc:title>flower</oslc:title><foaf:Person><foaf:name>William B. Bird</foaf:name><foaf:yead>1953</foaf:yead></foaf:Person></oslc:Comment></rdf:RDF>})
  end

end
