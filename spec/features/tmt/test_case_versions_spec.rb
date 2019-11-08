require 'spec_helper'

describe "Tmt::TestCaseVersions" do
  describe "GET /test_case_version" do
    let(:type) { create(:test_case_type, has_file: true) }
    let(:test_case) { create(:test_case, type: type) }
    let(:version) { create(:test_case_version, test_case: test_case) }
    let(:project) { test_case.project }
    let(:author) { version.author}

    it "should show name of comment" do
      project.add_member(author)
      sign_in author
      visit project_test_case_version_path(project, test_case, version)
      page.should have_content(version.comment)
    end

    it "should show execution list" do
      project.add_member(author)
      sign_in author
      execution = create(:execution, version: version)
      visit project_test_case_version_path(project, test_case, version)
      page.should have_content("List of executions")
      page.should have_content("Identifier Version id Test Run Executor Status Created at")
    end

    it "should not show execution list when version hasn't included executions" do
      project.add_member(author)
      sign_in author
      version.executions.delete_all
      visit project_test_case_version_path(project, test_case, version)
      page.should_not have_content("List of executions")
    end

  end


end
