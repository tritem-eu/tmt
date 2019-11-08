require 'spec_helper'

describe Oslc::Qm::TestScript::Resource do
  include Support::Oslc

  let(:peter) { create(:user) }
  let(:john) { create(:user) }
  let(:oliver) { create(:user) }

  let(:project) do
    project = create(:project)
    project.add_member(peter)
    project.add_member(john)
    project
  end

  let(:test_case) do
    create(:test_case, project: project)
  end

  let(:version) do
    create(:test_case_version,
      test_case: test_case,
      author: peter,
      comment: "Comment for TestScript instance"
    )
  end

  let(:xml) do
    content = ::Oslc::Qm::TestScript::Resource.new(version).to_xml
    Nokogiri::XML(content)
  end

  let(:rdf) do
    content = ::Oslc::Qm::TestScript::Resource.new(version).to_rdf
    Nokogiri::XML(content)
  end

  def doc(format)
    resource = ::Oslc::Qm::TestScript::Resource.new(version)
    content = ''
    if format == :rdf
      content = resource.to_rdf
    elsif format == :xml
      content = resource.to_xml
    end
    Nokogiri::XML(content)
  end

  it "should show type" do
    doc(:rdf).xpath("//rdf:type").to_s.should eq('<rdf:type rdf:resource="http://open-services.net/ns/qm#TestScript"/>')
    doc(:xml).xpath("//rdf:type").to_s.should eq('')
  end

  [:rdf, :xml].each do |format|
    before do
      ready(version, project, test_case, john, peter, oliver)
      User.all.should include(john, peter, oliver)
    end

    it "should be wrapped by 'rdf:RDF' property" do
      doc(format).xpath("//rdf:RDF").size.should eq(1)
    end

    it "should show 'dcterms:identifier' property" do
      url = server_url "/oslc/qm/service-providers/#{project.id}/test-scripts/#{version.id}"
      doc(format).xpath("//dcterms:identifier").text.should eq url
    end

    it "should show 'oslc:serviceProvider' property" do
      url = server_url "/oslc/qm/service-providers/#{project.id}"
      doc(format).at_xpath("//oslc:serviceProvider").attributes['resource'].value.should eq url
    end

    it "should show 'dcterms:contributor' property" do
      list = doc(format).xpath("//dcterms:contributor")
      urls = list.map{ |item| item.attributes['resource'].value }
      peter_url = server_url "/oslc/users/#{peter.id}"
      john_url = server_url "/oslc/users/#{john.id}"
      urls.should match_array [peter_url, john_url]
    end

    it "should show 'dcterms:creator' property" do
      url = server_url "/oslc/users/#{version.author_id}"
      doc(format).at_xpath("//dcterms:creator").attributes['resource'].value.should eq url
    end

    it "should show 'oslc_qm:executionInstructions' property" do
      url = server_url "/oslc/qm/service-providers/#{project.id}/test-scripts/#{version.id}/download"
      doc(format).at_xpath("//oslc_qm:executionInstructions").attributes['resource'].value.should eq url
    end

    it "should show 'dcterms:modified' property" do
      date = Support::Oslc::Date.new(version.updated_at).iso8601
      doc(format).xpath("//dcterms:modified").text.should eq date
    end

    it "should show 'dcterms:created' property" do
      date = Support::Oslc::Date.new(version.created_at).iso8601
      doc(format).xpath("//dcterms:created").text.should eq date
    end

    it "should show 'dcterms:description' property" do
      doc(format).xpath("//dcterms:description").text.should eq version.comment
    end

    it "should show 'dcterms:title' property" do
      doc(format).xpath("//dcterms:title").text.should eq version.comment
    end

    it "should show 'oslc:instanceShape' property" do
      url = server_url("/oslc/qm/resource-shapes/test-script")
      doc(format).at_xpath("//oslc:instanceShape").attributes['resource'].value.should eq url
    end
  end

end
