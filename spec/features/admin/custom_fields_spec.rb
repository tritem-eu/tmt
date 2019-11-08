require 'spec_helper'

feature "TestCaseCustomFields" do
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }
  let(:enumeration) { create(:enumeration_for_priorities) }

  before do
    sign_in admin
    ready(project, enumeration)
  end

  context "visit index page" do
    scenario "User can see list of custom fields" do
      visit admin_test_case_custom_fields_path
      expect(page.status_code).to eq(200)
    end
  end

  context "visit new page" do
    scenario "Admin can select Project" do
      visit new_admin_test_case_custom_field_path
      expect(page.current_path).to eq(new_admin_test_case_custom_field_path)
      page.should have_content "Test Case Custom Field"
      expect(page.status_code).to eq(200)
      within("form") do |object|
        select project.name
        fill_in "custom_field_name", with: "ExampleCustomField"
        click_button ""
      end
      custom_field = Tmt::TestCaseCustomField.where(name: 'ExampleCustomField').last
      custom_field.project.should eq(project)
    end

    scenario "Admin can select Enum type" do
      visit new_admin_test_case_custom_field_path
      click_link('Enumeration')
      expect(page.current_url).to include(new_admin_test_case_custom_field_path(type_name: :enum))
      page.should have_content "Test Case Custom Field"
      expect(page.status_code).to eq(200)
      within("form") do |object|
        select enumeration.name
        fill_in "custom_field_name", with: "ExampleCustomField"
        click_button ""
      end
      custom_field = Tmt::TestCaseCustomField.where(name: 'ExampleCustomField').last
      custom_field.enumeration.should eq(enumeration)
    end

    scenario "Admin can create new custom field" do
      visit new_admin_test_case_custom_field_path
      click_link('String')
      expect(page.current_url).to include(new_admin_test_case_custom_field_path(type_name: :string))
      expect(page.status_code).to eq(200)
      within("form") do |object|
        fill_in "custom_field_name", with: "ExampleCustomField"
        click_button ""
      end

      new_custom_field = Tmt::TestCaseCustomField.last
      expect(page.current_url).to eq(admin_test_case_custom_field_url(new_custom_field))
      page.should have_content "Custom Field was successfully created"
      expect(page.status_code).to eq(200)
    end

    scenario "User admin can not create new custom field" do
      visit new_admin_test_case_custom_field_path
      click_link('String')
      expect(page.current_url).to include(new_admin_test_case_custom_field_path(type_name: :string))
      within("form") do |object|
        fill_in "custom_field_description", with: "Description Custom Field"
        click_button ""
      end
      expect(page.current_path).to eq(admin_test_case_custom_fields_path)
      page.should have_content "Description Custom Field"
    end

    scenario "Admin can select integer type" do
      visit new_admin_test_case_custom_field_path
      page.should_not have_content "Lower limit"
      click_link('Integer')
      expect(page.current_url).to include(new_admin_test_case_custom_field_path(type_name: :int))
      page.should have_content "Lower limit"
    end

  end

  context "visit edit page" do
    scenario "Admin should see selected project and enumeration" do
      custom_field = create(:test_case_custom_field_for_enumeration)
      visit edit_admin_test_case_custom_field_path(custom_field)
      expect(page.current_path).to eq(edit_admin_test_case_custom_field_path(custom_field))
      expect(page.status_code).to eq(200)
      find("#custom_field_type_name").value.should eq('Enumeration')
      find("#custom_field_enumeration_id").value.should eq(custom_field.enumeration.id.to_s)
    end
  end
end
