require 'spec_helper'

describe Oslc::Qm::TestCase::Resource do
  let(:user) { create(:user) }
  let(:foreign_user) { create(:user) }

  let(:project) do
    project = test_case.project
    project.add_member(user)
    project
  end

  let(:test_case) do
    test_case = create(:test_case, name: "Pushing \"stop\" button.", description: "User is pushing \"stop\" button.")
    create(:test_case_version, test_case: test_case)
    test_case
  end

  let(:test_script) do
    test_case.versions[0]
  end

  let(:next_test_case) do
    create(:test_case, name: "Closing window", description: "User is closing window.")
  end

  def resource(oslc_properties=nil)
    ::Oslc::Qm::TestCase::Resource.new(test_case, {project: project, oslc_properties: oslc_properties})
  end

  def doc(parser)
    content = ''
    if parser == :rdf
      content = resource.to_rdf
    elsif parser == :xml
      content = resource.to_xml
    end
    Nokogiri::XML(content)
  end

  before do
    ready(test_case, next_test_case, foreign_user, user)
  end

  it "should show type" do
    doc(:rdf).xpath("//rdf:type").to_s.should eq('<rdf:type rdf:resource="http://open-services.net/ns/qm#TestCase"/>')
    doc(:xml).xpath("//rdf:type").to_s.should eq('')
    doc(:xml).to_s.should include('TestCase')
  end

  [:xml, :rdf].each do |format|
    describe "for '#{format.to_s.upcase}' format" do

      it "should show 'dcterms:contributor' property" do
        url = server_url("/oslc/users/#{user.id}")
        doc(format).xpath("//dcterms:contributor").should have(1).item
        doc(format).at_xpath("//dcterms:contributor").attributes['resource'].to_s.should eq url
      end

      it "should show 'oslc:instanceShape' property" do
        url = server_url('/oslc/qm/resource-shapes/test-case')
        doc(format).at_xpath("//oslc:instanceShape").attributes['resource'].to_s.should eq url
      end

      it "should show 'dcterms:identifier' property" do
        result = doc(format).at_xpath('//dcterms:identifier').text
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}")
      end

      it "should show 'dcterms:created' property" do
        time = Support::Oslc::Date.new(test_case.created_at).iso8601
        doc(format).xpath('//dcterms:created').text.should eq time
      end

      it "should show 'dcterms:modified' property" do
        time = Support::Oslc::Date.new(test_case.updated_at).iso8601
        doc(format).xpath("//dcterms:modified").text.should eq time
      end

      it "should show 'oslc:serviceProvider' property" do
        result = doc(format).xpath('//oslc:serviceProvider').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}")
      end

      it "should show 'oslc_qm:usesTestScript' property" do
        result = doc(format).xpath('//oslc_qm:usesTestScript').first.attributes['resource'].value
        result.should eq server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{test_script.id}")
      end

      it "should show 'dcterms:creator' property" do
        result = doc(format).xpath('//dcterms:creator').first.attributes['resource'].value
        result.should eq server_url("/oslc/users/#{test_case.creator_id}")
      end

      it "should show 'dcterms:description' property" do
        doc(format).xpath('//dcterms:description').text.should eq(test_case.description)
      end

      it "should show 'dcterms:title' property" do
        doc(format).xpath('//dcterms:title').text.should eq test_case.name
      end
    end
  end
end
