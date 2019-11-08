require 'spec_helper'

feature "Show Home" do
  let(:project) { create(:project) }
  let(:project2) { create(:project) }

  let(:admin) { create(:admin) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  scenario "with user not logged in" do
    sign_in
    visit root_path
    page.has_css?('.project-table').should be false
  end

  scenario "with logged user and empty list of projects" do
    sign_in user
    ::Tmt::Project.stub(:user_projects) { [] }
    visit root_path
    page.has_text?('Ask Your Admin To Create')
  end

  scenario "with logged user" do
    sign_in user
    ready(project)
    page.has_no_text?(project.name)
    visit root_path
    page.has_css?('.project-table').should be true
    page.has_text?(project.name)
  end

  scenario "with logged in user" do
    sign_in admin
    ready(project)
    visit root_path
    expect(page.status_code).to eq(200)
    page.has_css?('.project-table').should be false
  end
end
