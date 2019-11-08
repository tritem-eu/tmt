require 'spec_helper'

describe Oslc::Qm::TestScript::Query do

  let(:john) { create(:user, name: 'John') }
  let(:oliver) { create(:user, name: 'Oliver') }
  let(:peter) { create(:user, name: 'Peter') }

  let(:project) do
    project = create(:project)
    project.add_member(john)
    project.add_member(oliver)
    project
  end

  let(:version_open_window) do
    create(:test_case_version,
      test_case: create(:test_case, project: project),
      author: john,
      comment: 'Open window.'
    )
  end

  let(:version_turn_on_light) do
    create(:test_case_version,
      test_case: create(:test_case, project: project),
      author: oliver,
      comment: 'Turn on light.'
    )
  end

  let(:version_for_another_project) do
    create(:test_case_version,
      test_case: create(:test_case),
      author: oliver,
      comment: 'Close door.'
    )
  end

  def query(syntax)
    Oslc::Qm::TestScript::Query.new(provider: project).where(syntax)
  end

  before do
    ready(project, john, peter, oliver)
    ready(version_for_another_project, version_turn_on_light, version_open_window)
     Tmt::TestCaseVersion.all.should match_array [
       version_for_another_project,
       version_turn_on_light,
       version_open_window
     ]
   end

   it "should return all versions when query syntax is empty" do
     result = query(nil)
     result.should match_array [
       version_turn_on_light,
       version_open_window
     ]
   end

  it "should return versions for appropriate 'dcterms:creator' property" do
    identifier = server_url("/oslc/users/#{john.id}")
    result = query("dcterms:creator=\"#{identifier}\"")
    result.should match_array [version_open_window]
  end

  it "should return versions when creator is Oliver" do
    result = query("dcterms:creator{foaf:name=\"Oliver\"}")
    result.should match_array [version_turn_on_light]
  end

  it "should return versions for appropriate 'dcterms:identifier' property" do
    identifier = server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{version_turn_on_light.id}")
    result = query("dcterms:identifier=\"#{identifier}\"")
    result.should match_array [version_turn_on_light]
  end

  it "should return versions for appropriate 'dcterms:title' property" do
    result = query("dcterms:title=\"#{version_turn_on_light.comment}\"")
    result.should match_array [version_turn_on_light]
  end

  it "should return versions for appropriate 'dcterms:description' property" do
    result = query("dcterms:title=\"#{version_open_window.comment}\"")
    result.should match_array [version_open_window]
  end

  it "should return versions for appropriate 'oslc:serviceProvider' property" do
    url = server_url("/oslc/qm/service-providers/#{project.id}")
    result = query("oslc:serviceProvider=<#{url}>")
    result.should match_array [
      version_turn_on_light,
      version_open_window
    ]
  end

   it "should return versions for appropriate 'oslc:instanceShape' property" do
     url = server_url('/oslc/qm/resource-shapes/test-script')
     result = query("oslc:instanceShape=<#{url}>")
     result.should match_array [
       version_turn_on_light,
       version_open_window
     ]
     result = query("oslc:instanceShape=\"\"")
     result.should match_array []
   end

  it "should return versions for appropriate 'oslc_qm:executionInstructions' property" do
    url = server_url("/oslc/qm/service-providers/#{project.id}/test-scripts/#{version_turn_on_light.id}/download")
    result = query("oslc_qm:executionInstructions=<#{url}>")
    result.should match_array [version_turn_on_light]
  end

  it "should return versions for appropriate 'dcterms:contributor' property" do
    url = server_url("/oslc/users/#{oliver.id}")
    result = query("dcterms:contributor=<#{url}>")
    result.should match_array [version_turn_on_light, version_open_window]
  end

  it "should return versions for appropriate 'dcterms:modified' property" do
    time = Support::Oslc::Date.new(version_open_window.updated_at).iso8601
    result = query("dcterms:modified=\"#{time}\"")
    result.should match_array [version_open_window]
  end

  it "should return versions for appropriate 'dcterms:created' property" do
    time = Support::Oslc::Date.new(version_open_window.created_at).iso8601
    result = query("dcterms:created=\"#{time}\"")
    result.should match_array [version_open_window]
  end

end
