require 'spec_helper'

feature "Campaigns list" do

  let(:admin) { create(:admin) }

  before do
    sign_in admin
  end

  scenario "admin can change name of application" do
    visit admin_cfgs_path
    title = "Mazda"
    page.should_not have_content(title)

    within "#edit_cfg" do
      fill_in "cfg_instance_name", with: title
      click_button ""
    end
    page.should have_content(title)
    expect(page.current_path).to eq(admin_cfgs_path)
  end

end
