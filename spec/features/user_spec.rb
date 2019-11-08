require 'spec_helper'

# As a visitor to the website
# I want to see registered users listed on the homepage
# so I can know if the site has users
feature "Show Users" do
  scenario "Viewing users" do
    @user = create(:admin)
    sign_in_as_a_valid_user
    page.should have_selector "#flash_notice", text: "Signed in successfully."
    page.current_url.should eq(root_url)
    visit '/admin/users'
    page.should have_content "Users"

    page.should have_content @user.email
  end

end

feature "Change user role" do
  scenario "Admin can change role of user" do
    @user = create(:admin)
    sign_in_as_a_valid_user
    page.should have_selector "#flash_notice", text: "Signed in successfully."
    page.current_url.should eq(root_url)
    new_user = create(:user)
    new_user.roles.pluck(:name).should eq(['user'])
    visit admin_users_path
    page.find('a[href="' + "#{edit_role_admin_user_path(new_user.id)}" '"]').click
    page.current_url.should eq(edit_role_admin_user_url(new_user.id))
    admin_role = Role.where(name: 'admin').first
    page.find("input[type='radio'][value='#{admin_role.id}']").click
    click_button('Change Role')
    page.should have_content("User's role was successfully updated")
  end
end

feature "Edit User" do
  scenario "I sign in and edit my account" do
    @user = create(:user)

    sign_in_as_a_valid_user
    page.should have_selector "#flash_notice", text: "Signed in successfully."
    expect(page.current_url).to eq(root_url)
    click_link "Account settings"

    within(".edit_user") do
      fill_in "user_name", :with => "newname"
      fill_in "user_current_password", :with => @user.password
      click_button "Update"
    end

    page.should have_content "You updated your account successfully."
  end
end

feature "New User" do
  scenario "I sign in as admin and create new account" do
    @user = create(:admin)
    sign_in_as_a_valid_user
    page.should have_selector "#flash_notice", text: "Signed in successfully."
    expect(page.current_url).to eq(root_url)
    visit new_admin_user_path
    expect do
      within("#new_user") do
        fill_in "user_email", :with => '20140710.1526@example.com'
        fill_in "user_name", :with => "20140710 15:26"
        fill_in "user_password", :with => 'secret123'
        fill_in "user_password_confirmation", :with => 'secret123'
        click_button "Create"
      end
    end.to change(User, :count).by(1)
    user = User.last
    user.email.should eq('20140710.1526@example.com')
    user.name.should eq('20140710 15:26')

    page.should have_content "User was successfully created"
  end
end

feature "Show User" do
  let(:user) { create(:user) }

  let(:test_case) { create(:test_case, name: 'Example test case', project: project) }

  let(:project) {
    project = create(:project)
    project.add_member(user)
    project
  }

  scenario "with active user activity" do
    sign_in user
    create(:user_activity, observable: test_case, project: project)
    visit user_path(user)
    expect(page.current_url).to eq(user_url user)

    page.should have_selector "h2", text: "User"
    page.should have_selector "div", text: "Example test case"
  end
end