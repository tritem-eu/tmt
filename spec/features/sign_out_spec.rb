require 'spec_helper'

# To protect my account from unauthorized access
# A signed in user
# Should be able to sign out
feature "Sign out" do
  scenario "User signs out successfully" do
    @user = create(:user)

    sign_in_as_a_valid_user
    page.should have_selector "#flash_notice", text: "Signed in successfully."
    expect(page.current_url).to eq(root_url)

    visit '/users/sign_out'
    page.should have_selector "#flash_notice", text: "Signed out successfully."
    expect(page.current_url).to eq(root_url)
  end
end
