require 'spec_helper'

feature "Campaigns list" do
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }

  scenario "member has access to campaign list" do
    sign_in admin

    visit admin_campaigns_path
    expect(page.current_path).to eq(admin_campaigns_path)
  end

  scenario "admin has access to campaign list" do
    sign_in admin

    visit admin_campaigns_path
    expect(page.current_path).to eq(admin_campaigns_path)
  end

  scenario "admin sees a statement about empty list of projects" do
    sign_in admin

    ::Tmt::Project.stub(:all) {[]}
    visit admin_campaigns_path
    page.should have_content("Before using this section, please create at least one project")
  end

  scenario "admin sees list of 2 projects" do
    sign_in admin

    project = create(:project, name: "Lucky Luke")
    project2 = create(:project, name: "Ruby on Rails")
    visit admin_campaigns_path(project_id: project2.id)
    page.should have_content "Lucky Luke"
    page.should have_content "Ruby on Rails"
  end

  scenario "admin can create new campaign with name 'Laser'" do
    sign_in admin

    ready(project)
    visit admin_campaigns_path(project_id: project.id)

    page.should_not have_content "Laser"
    click_link('New')
    page.current_url.should include('/admin/campaigns/new?project_id=1')
    within "#new_campaign" do
      fill_in "campaign_name", with: "Laser"
      click_button ""
    end
    page.current_url.should include('/admin/campaigns?project_id=1')

    page.should have_content "Laser"
    page.all('.panel', text: "New campaign").should be_empty
  end
end

feature "Edit campaign" do

  let(:admin) { create(:admin) }

  let(:project) { create(:project) }

  let(:campaign) { create(:campaign, project: project, name: "Laser") }

  scenario "Admin can change name Laser to Resal" do
    sign_in admin
    ready(campaign)
    visit edit_admin_campaign_path(campaign)
    expect(page.current_path).to eq(edit_admin_campaign_path(campaign))
    page.should_not have_content "Resal"
    within "#edit_campaign" do
      fill_in "campaign_name", with: "Resal"
      click_button ""
    end
    page.should have_content "Resal"
  end

end

feature "Show campaign" do

  let(:admin) { create(:admin) }

  let(:project) { create(:project) }

  let(:campaign) { create(:campaign, project: project, name: "Laser") }

  scenario "Admin can see campaign name 'Laser'" do
    sign_in admin
    ready(campaign)
    visit project_campaign_path(project, campaign)
    expect(page.current_path).to eq(project_campaign_path(project, campaign))
    page.should have_content "Laser"
  end

end
