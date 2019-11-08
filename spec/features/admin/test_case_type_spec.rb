require 'spec_helper'

feature "Tmt::TestCaseType" do

  let(:admin) { create(:admin)}
  let(:test_case_type) { create(:test_case_type) }

  scenario "should create new TestCaseType" do
    sign_in admin
    visit new_admin_test_case_type_path
    expect do
      within '#new_test_case_type' do
        fill_in "test_case_type_name", with: "Example type"
        fill_in "test_case_type_extension", with: "seq"
        click_button ""
      end
    end.to change(Tmt::TestCaseType, :count).by(1)
  end

  scenario "should render index template with empty types" do
    sign_in admin
    visit admin_test_case_types_path
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq(admin_test_case_types_path)
  end

  scenario "should render index template with one types" do
    sign_in admin
    create(:test_case_type, name: "seq12345")
    visit admin_test_case_types_path
    page.should have_content("seq12345")
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq(admin_test_case_types_path)

  end

  scenario "should edit an existing TestCaseType on sequence type" do
    sign_in admin
    ready(test_case_type)
    visit edit_admin_test_case_type_path(test_case_type)

    within '#edit_test_case_type' do
      fill_in "test_case_type_name", with: "Edit Example type"
      fill_in "test_case_type_extension", with: "dat"
      select 'sequence', from: "test_case_type_converter"
      click_button ""
    end
    test_case_type.reload.name.should eq("Edit Example type")
    test_case_type.reload.extension.should eq("dat")
    test_case_type.reload.converter.should eq('sequence')
  end

  scenario "should edit an existing TestCaseType on none type" do
    sign_in admin
    ready(test_case_type)
    visit edit_admin_test_case_type_path(test_case_type)

    within '#edit_test_case_type' do
      fill_in "test_case_type_name", with: "Edit Example type"
      fill_in "test_case_type_extension", with: "dat"
      select 'None', from: "test_case_type_converter"
      click_button ""
    end
    test_case_type.reload.name.should eq("Edit Example type")
    test_case_type.reload.extension.should eq("dat")
    test_case_type.reload.converter.should eq('')
  end

end
