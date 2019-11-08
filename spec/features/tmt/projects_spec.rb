require 'spec_helper'

feature "Show Projects" do
  let(:admin) { create(:admin) }
  scenario "with logged in user" do
    sign_in admin
    visit admin_projects_path
    expect(page.status_code).to eq(200)
    expect(page.current_url).to eq(admin_projects_url)
    page.should have_content "Projects"
  end
end

feature "GET show" do
  let(:project) { create(:project) }
  let(:campaign) { create(:campaign, project: project) }
  let(:test_run) { create(:test_run, campaign: campaign)}
  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  scenario "with empty test cases" do
    sign_in user
    visit project_path(project)
    expect(page.current_url).to eq(project_url(project))
  end

  scenario "with one test case" do
    sign_in user
    create(:test_case, project: project)
    visit project_path(project)
    expect(page.current_url).to eq(project_url(project))
  end

  scenario "with one test run" do
    sign_in user
    create(:test_run, campaign: campaign)
    visit project_path(project)
    expect(page.current_url).to eq(project_url(project))
  end

  scenario "with one test run but with closed campaign" do
    sign_in user
    create(:test_run, campaign: campaign)
    campaign.close
    visit project_path(project)
    expect(page.current_url).to eq(project_url(project))
    page.all('a', text: 'View all test runs').should_not be_empty
  end
end

feature "Create project" do
  let(:admin) { create(:admin) }
  scenario "with logged in user" do
    sign_in admin
    visit new_admin_project_path
    expect(page.current_url).to eq(new_admin_project_url)

    within "#new_project" do
      fill_in "project_name", with: "New project"
      fill_in "project_description", with: "Description of project"
      click_button ""
    end

    page.should have_content "Project was successfully created"
    page.should have_content "Description of project"
  end
end

feature "Update project" do
  let(:project) { create(:project) }
  let(:test_case_type) { create(:test_case_type, name: "Sequence (all)") }
  let(:admin) { create(:admin) }

  before do
    sign_in admin
    ready(project, test_case_type)
    visit edit_admin_project_path(project)
    expect(page.current_url).to eq(edit_admin_project_url(project))
  end

  scenario "with logged in user" do
    within "#edit_project" do
      fill_in "project_name", with: "Updated edit"
      fill_in "project_description", with: "Updated description"
      find("option[value='#{test_case_type.id}']").select_option
      click_button ""
    end

    page.should have_content "Project was successfully updated"
    project.reload.default_type_id.should eq(test_case_type.id)
  end

  scenario "show setted default type" do
    page.should have_content test_case_type.name
  end
end
