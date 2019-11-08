require 'spec_helper'
describe Oslc::Qm::TestCase::CreationFactory do
  let(:content) do
    Tmt::XML::RDFXML.new(xmlns: {
      dcterms: :dcterms,
      rdf: :rdf,
    }, xml: {lang: :en}) do |xml|
      xml.add("dcterms:description") { "Description of resource" }
      xml.add("dcterms:title") { "Title of resource" }
      # xml.add("oslc_qm:usesTestScript")
    end.to_xml
  end

  let(:project) { create(:project) }
  let(:user) { create(:user) }
  it '#parse for correct content' do
    Oslc::Qm::TestCase::CreationFactory.new(content, project, user).parse.should eq({
      description: "Description of resource",
      name: "Title of resource"
    })
  end

  it '#parse for empty content' do
    expect do
      Oslc::Qm::TestCase::CreationFactory.new('', project, user).parse
    end.to raise_error
  end

end
