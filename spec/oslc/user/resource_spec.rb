require 'spec_helper'

describe Oslc::User::Resource do
  include Support::Oslc

  let(:user) { create(:user) }

  let(:xml) do
    content = ::Oslc::User::Resource.new(user).to_xml
    Nokogiri::XML(content)
  end

  let(:rdf) do
    content = ::Oslc::User::Resource.new(user).to_rdf
    Nokogiri::XML(content)
  end

  it "should connect with action" do
    xml.xpath("//rdf:RDF").size.should eq(1)
    url = rdf.xpath('//rdf:Description').first.attributes['about'].text
    url.should eq(server_url("/oslc/users/#{user.id}"))
    url = xml.xpath('//foaf:Person').first.attributes['about'].text
    url.should eq(server_url("/oslc/users/#{user.id}"))
  end

  it "should show type" do
    rdf.xpath("//rdf:type").to_s.should eq('<rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person"/>')
    xml.xpath("//rdf:type").to_s.should eq('')
  end

  [
    ['RDF', :rdf],
    ['XML', :xml]
  ].each do |format, function|
    it "shows mbox property for format #{format}" do
      get(function).xpath("//foaf:mbox").to_s.should eq("<foaf:mbox rdf:resource=\"mailto:#{user.email}\"/>")
    end

    it "shows name property for format #{format}" do
      get(function).xpath("//foaf:name").text.should eq(user.name)
    end
  end

end
