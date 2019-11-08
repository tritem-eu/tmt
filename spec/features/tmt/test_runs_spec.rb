require 'spec_helper'

feature "Tmt::TestRun" do
  let(:campaign) { create(:campaign, project: project) }

  let(:test_run) { create(:test_run, campaign: campaign) }
  let(:test_case) { create(:test_case, project: project,  name: 'test run - example title') }
  let(:project) { create(:project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  context "index page" do
    scenario "should render index for list" do
      visit project_test_runs_path(project, campaign_id: campaign.id)
      expect(page.status_code).to eq(200)
    end

    scenario "should render index for list without cloning option of test run" do
      sign_in user
      ready(test_run, campaign)
      visit project_test_runs_path(project, campaign_id: campaign.id)
      page.should have_link('Clone', href: clone_project_test_run_path(project, test_run))
      campaign.is_open = false
      campaign.save(validate: false)
      visit project_test_runs_path(project, campaign_id: campaign.id)
      page.should_not have_link('Clone', href: clone_project_test_run_path(project, test_run))
    end

    scenario "should render index for calendar" do
      sign_in user
      test_run.update(due_date: Date.new(2000, 2, 3))
      visit project_test_runs_path(project, campaign_id: campaign.id, active_tag: :calendar)
      expect(page.status_code).to eq(200)
      page.body.should include(test_run.name)
    end

    scenario "should render list of test runs for one day (calendar view)" do
      sign_in user
      test_runs = []
      Time.stub(:now) { Time.new(2000, 2, 4, 12)}
      7.times { |item| test_runs << create(:test_run, name: "TR - #{item}", campaign: campaign, due_date: Time.new(2014, 8, 1, 14)) }
      visit calendar_month_project_test_runs_path(project, 2014, 8, date: {year: 2014, month: 8})
      page.should_not have_content("TR - 6")
      click_link('more')
      expect(page.current_url).to include(calendar_month_day_project_test_runs_path(project, 2014, 8, 1))
      page.should have_content("TR - 6")
    end

    scenario "should find all test runs with phrase 'example*new' " do
      sign_in user
      create(:test_run, campaign: campaign, name: 'example new')
      create(:test_run, campaign: campaign, name: 'example_23_new')
      create(:test_run, campaign: campaign, name: 'example fake')
      visit project_test_runs_path(project, campaign_id: campaign.id)
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

  context 'new page' do
    scenario "should create new test run" do
      sign_in user
      visit new_project_campaign_test_run_path(project, campaign)
      expect(page.current_path).to eq(new_project_campaign_test_run_path(project, campaign))

      expect do
        within "#new_test_run" do
          fill_in "test_run_name", with: "Test run name"
          click_button ""
        end
      end.to change(Tmt::TestRun, :count).by(1)
      new_test_run = Tmt::TestRun.where(name: "Test run name").first
      expect(page.current_path).to eq(project_campaign_test_run_path(project, campaign, new_test_run))
    end
  end

  context "edit page" do
    scenario "should edit test run" do
      sign_in user
      visit edit_project_campaign_test_run_path(project, campaign, test_run)
      expect(page.current_path).to eq(edit_project_campaign_test_run_path(project, campaign, test_run))

      within "#edit_test_run" do
        fill_in "test_run_name", with: "Test run - updated"
        click_button ""
      end
      updated_test_run = Tmt::TestRun.where(name: "Test run - updated").first
      updated_test_run.should be_a(Tmt::TestRun)
      expect(page.current_path).to eq(project_campaign_test_run_path(project, campaign, updated_test_run))
    end

    scenario "should edit custom field of test run" do
      sign_in user
      ready(create(:test_run_custom_field, name: 'exampleCustomField', project: project))
      visit edit_project_campaign_test_run_path(project, campaign, test_run)
      expect(page.current_path).to eq(edit_project_campaign_test_run_path(project, campaign, test_run))
      page.all('[name="test_run[custom_field_values][1[value]]"]').first.set("BBCustomField")
      page.find('#edit_test_run input[type="submit"]').click
      test_run.reload.custom_field_values.first.string_value.should eq('BBCustomField')
    end

  end

  context 'show page' do
    scenario "should render show" do
      sign_in user
      visit project_campaign_test_run_path(project, campaign, test_run)
      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq(project_campaign_test_run_path(project, campaign, test_run))
    end

    scenario "should add new TestCaseVersion record to TestRun record using list without js" do
      sign_in user
      test_case = create(:test_case, name: 'Test case 18.12.2014 10:20', project: project)
      create(:test_case_version, test_case: test_case)
      visit project_campaign_test_run_path(project, campaign, test_run)
      page.should_not have_content(test_case.name)
      click_link("Add Test Cases")
      page.should have_content('Select test cases')
      page.click_link('Add to test run')
      page.should have_content('▸ Test case 18.12.2014 10:20')
      page.click_button('Add')
      page.should have_content('Test case 18.12.2014 10:20')
      page.should have_content('Add Test Cases')
    end

    scenario "should redirect to index of test runs when user try delete test run from show view" do
      sign_in user
      ready(test_run)
      visit project_campaign_test_run_path(project, campaign, test_run)
      test_run.reload.deleted_at.should be_nil
      find('.side-nav a[data-method="delete"]').click
      test_run.reload.deleted_at.should_not be_nil
      expect(page.current_url).to eq(project_test_runs_url project)
    end

  end

  scenario "should redirect to referrer when user try delete test run from dashboard" do
    sign_in user
    ready(test_run)
    visit project_path(project)
    test_run.reload.deleted_at.should be_nil
    find('.panel-tmt a[data-method="delete"]').click
    test_run.reload.deleted_at.should_not be_nil
    expect(page.current_url).to eq(project_url project)
  end

end
