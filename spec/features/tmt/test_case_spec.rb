require 'spec_helper'

feature "Test Case" do
  let(:admin) { create(:admin) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:project) { create(:project, default_type_id: test_case_type.id) }
  let(:campaign) { create(:campaign, project: project) }

  let(:test_case_type) { create(:test_case_type) }

  context "index view" do
    scenario "should show an index view " do
      sign_in user
      visit project_test_cases_path(project)
      page.status_code.should eq(200)
    end

    scenario "should find all test cases with phrase 'example*new' " do
      sign_in user
      create(:test_case, project: project, name: 'example new')
      create(:test_case, project: project, name: 'example_23_new')
      create(:test_case, project: project, name: 'example fake')
      visit project_test_cases_path(project)
      page.should have_content('example_23_new')
      page.should have_content('example new')
      page.should have_content('example fake')
      within '.search-form' do
        fill_in 'search', with: 'example*new'
        click_button ''
      end
      page.should have_content('example_23_new')
      page.should have_content('example new')
      page.should_not have_content('example fake')
    end

  end

  context "New view" do
    scenario "Viewing test case" do
      visit new_project_test_case_path(project)
      expect(page.status_code).to eq(200)
    end

    scenario "Viewing test case with default selected type" do
      sign_in user
      visit new_project_test_case_path(project)
      page.find('select option[selected="selected"]').value.should eq(project.default_type_id.to_s)
    end

    scenario "Click save" do
      project = create(:project)
      sign_in admin
      visit new_project_test_case_path(project)
      page.should have_content "New Test Case"
      within("#new_test_case") do
        fill_in "test_case_name", with: "example name"
        click_button "Save"
      end
      page.should have_content "Test Case was successfully created"

      expect(page.status_code).to eq(200)
    end
  end
end

feature "Add Version" do
  let(:project) { create(:project) }
  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:type) { create(:test_case_type, has_file: true)}

  let(:test_case) do
    create(:test_case, project: project, creator: user, type: type, name: 'Example')
  end

  before do
    sign_in user
    test_case
  end

  scenario "should upload version" do
    visit project_test_case_path(project, test_case)
    within("form.new_test_case_version") do
      fill_in "test_case_version[comment]", with: "Example comment"
      attach_file 'test_case_version[datafile]', Rails.root.join('spec', 'files', 'main_sequence.seq').to_s
    end
    page.find('form.new_test_case_version .btn').click
    sleep 1
    Tmt::TestCaseVersion.where(comment: 'Example comment').size.should eq(1)
  end
end

feature "Show Test Case" do
  let(:project) { create(:project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:type) { create(:test_case_type, has_file: true)}

  let(:test_case) do
    create(:test_case, project: project, creator: user, type: type, name: 'Example')
  end

  before do
    sign_in user
    test_case
  end

  context "for toggle_steward action" do
    scenario "should show unlock padlock" do
      test_case.update(steward_id: nil)
      visit project_test_case_path(project, test_case)
      page.should have_selector('a.test_case_link_unlock')
      page.should have_selector('.test_case_link_unlock .text-success')
      page.should_not have_selector('a.test_case_link_lock')
      page.find('a.test_case_link_unlock').click
      expect(page.status_code).to eq(200)
      page.should have_selector('a.test_case_link_lock')
      page.should_not have_selector('a.test_case_link_unlock')
    end

    scenario "should show lock padlock where curren user can toggle padlock" do
      test_case.update(steward_id: user.id)
      visit project_test_case_path(project, test_case)
      page.should have_selector('a.test_case_link_lock')
      page.should have_selector('.test_case_link_lock .text-success')
      page.should_not have_selector('a.test_case_link_unlock')
      page.find('a.test_case_link_lock').click
      expect(page.status_code).to eq(200)
      page.should have_selector('a.test_case_link_unlock')
      page.should_not have_selector('a.test_case_link_lock')
    end

    scenario "should show lock padlock where curren user cannot toggle padlock" do
      test_case.update(steward_id: 0)
      visit project_test_case_path(project, test_case)
      page.should_not have_selector('.test_case_link_lock')
      page.should_not have_selector('.fa-lock.text-dangerous')
    end
  end

  scenario "should show empty list of versions" do
    visit project_test_case_path(project, test_case)
    expect(page.status_code).to eq(200)
    page.should_not have_content("Progress")
  end

  scenario "should show list of versions" do
    version = create(:test_case_version, comment: "Example comment",test_case_id: test_case.id)
    visit project_test_case_path(project, test_case)
    expect(page.status_code).to eq(200)
    page.should have_content("Example comment")
  end

  scenario "should show list of versions" do
    version = create(:test_case_version, comment: "Example comment",test_case_id: test_case.id, revision: "git-hash")
    Tmt::TestCaseVersion.any_instance.stub(:content).and_return("Example content of version")
    visit project_test_case_path(project, test_case)
    expect(page.status_code).to eq(200)
    page.should have_content("Example comment")
  end

  scenario "should show a content of last version" do
    test_case.type = create(:test_case_type, has_file: true, converter: 'html')
    test_case.save(validate: false)
    version = create(:test_case_version, comment: "Example comment",test_case_id: test_case.id, revision: "git-hash")
    Tmt::TestCaseVersion.any_instance.stub(:content).and_return("Example content of version")
    visit project_test_case_path(project, test_case)
    expect(page.status_code).to eq(200)
    page.body.should include("<object data=\"/projects/#{project.id}/test-cases/#{test_case.id}/versions/#{version.id}/only-file")
  end

  
end

feature "Show Test Case and edit version" do
  let(:project) { create(:project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:type) { create(:test_case_type, has_file: false)}

  let(:test_case) do
    create(:test_case, project: project, creator: user, type: type)
  end

  before do
    sign_in user
    test_case
  end

  scenario "should show empty list of versions" do
    visit project_test_case_path(project, test_case)
    expect(page.status_code).to eq(200)
    page.should_not have_content("Progress")
  end

  scenario "should show list of versions" do
    visit project_test_case_path(project, test_case)

    within("#new_test_case_version") do
      fill_in "test_case_version_comment", with: "CoMmEnT"
      fill_in "test_case_version_datafile", with: "<script>123456789</script>"
      click_button ""
    end
    expect(page.current_path).to eq(project_test_case_path(project, test_case))
    page.should have_content("script-CoMmEnT")
  end
end

feature "Edit Test Case" do
  let(:test_case_type) { create(:test_case_type) }

  let(:project) { create(:project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:test_case) do
    create(:test_case, project: project, creator: user, type: test_case_type)
  end

  scenario "Viewing test case with selected type" do
    sign_in user
    visit edit_project_test_case_path(project, test_case)
    page.find('select option[selected="selected"]').value.should eq(test_case.type_id.to_s)
  end
end
