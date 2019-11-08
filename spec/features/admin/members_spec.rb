require 'spec_helper'

feature Tmt::Member do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:john_user) { create(:user) }
  let(:maggie_user) { create(:user) }

  let(:project) { create(:project, name: "example-project-12345") }

  before do
    sign_in admin
  end

  scenario "admin sees a statement about empty list of projects" do
    ::Tmt::Project.stub(:all) {[]}
    visit admin_members_path
    page.should have_content("Before using this section, please create at least one project")
  end

  scenario "admin sees list of projects " do
    ready(project)
    visit admin_members_path
    page.should have_content project.name
  end

  scenario "admin can add a user to project" do
    ready(project, user, john_user, maggie_user)
    visit admin_members_path
    project.members.should be_empty
    idd = page.all('.new_member input[type="submit"]').last.click
    project.reload.members.should_not be_empty
  end

  scenario "admin can remove a user from project" do
    ready(project, user, john_user, maggie_user)
    project.add_member(john_user)
    visit admin_members_path
    project.reload.members.should have(1).item
    page.all('.edit_tmt_member input[type="submit"]').last.click
    project.reload.members.should be_empty
  end
end
