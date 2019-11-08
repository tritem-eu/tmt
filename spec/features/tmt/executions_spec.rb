require 'spec_helper'

feature "Show list Executions" do
  let(:project) { create(:project) }

  let(:campaign) { create(:campaign, project: project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:type) { create(:test_case_type, has_file: true)}

  let(:test_case) do
    create(:test_case, project: project, creator: user, type: type)
  end

  let(:test_run) { create(:test_run, campaign: campaign) }

  before do
    sign_in user
  end

  scenario "shows list of test cases to choose" do
    ready(test_run)
    test_case_id = create(:test_case, project: project)
    Tmt::Project.any_instance.stub(:test_cases) { ::Tmt::TestCase.where(id: test_case_id)}

    visit select_test_cases_project_campaign_executions_path(project, campaign, test_run_id: test_run.id)
    expect(page.status_code).to eq(200)
    page.should_not have_content("List of tset runs")
  end

  scenario "show list of test cases to choose for format js" do
    ready(test_run)
    test_case_id = create(:test_case, project: project)
    Tmt::Project.any_instance.stub(:test_cases) { ::Tmt::TestCase.where(id: test_case_id)}
    visit select_test_cases_project_campaign_executions_path(project, campaign, test_run_id: test_run.id, format: :js)
    expect(page.status_code).to eq(200)
    page.should_not have_content("List of tset runs")
  end

  scenario "show list of test run to choose" do
    ready(test_case)
    Tmt::Project.any_instance.stub(:test_cases) {::Tmt::TestCase.where(id: create(:test_case, project: project))}
    visit select_test_run_project_campaign_executions_path(project, campaign, test_case_ids: [test_case.id])
    page.status_code.should eq(200)
    page.should have_content("Select")
  end

  scenario "show list of test run to choose for javaScript" do
    ready(test_case)
    Tmt::Project.any_instance.stub(:test_cases) {::Tmt::TestCase.where(id: create(:test_case, project: project))}
    visit select_test_run_project_campaign_executions_path(project, campaign, test_case_ids: [test_case.id], format: :js)
    expect(page.status_code).to eq(200)
    page.should have_content("Select")
  end

end

feature "GET /report" do
  let(:execution) { create(:execution) }
  let(:version) { execution.version }
  let(:test_run) { execution.test_run }
  let(:test_case) { execution.test_case }
  let(:campaign) { test_run.campaign }
  let(:project) { campaign.project }

  let(:member) do
    user = create(:user)
    project.add_member(user)
    user
  end

  scenario "should show name of comment" do
    test_run.update(executor: member, due_date: Time.now)
    test_run.set_status_planned
    sign_in member

    visit report_project_campaign_execution_path(project, campaign, execution)
    expect(page.status_code).to eq(200)
  end

  scenario "should show content of result" do
    sign_in member
    execution = create(:execution_with_short_report, test_run: test_run)
    visit report_project_campaign_execution_path(project, campaign, execution)
    expect(page.status_code).to eq(200)
    page.body.should include("<div class=\"file-content\"><span class=\"file-name\">short_report.html</span><object data=\"/projects/#{project.id}/campaigns/#{campaign.id}/executions/#{execution.id}/report-file\" height=\"100%\" onload=\"app.executions.event.changeObjectTagHeight()")
  end

end

feature "GET /upload_csv" do
  let(:execution) { create(:execution) }
  let(:version) { execution.version }
  let(:test_run) { execution.test_run }
  let(:test_case) { execution.test_case }
  let(:campaign) { test_run.campaign }
  let(:project) { campaign.project }

  let(:member) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:uploaded_file) do
    file = Tempfile.new('list_test_cases.csv')
    file << "id,name\n"
    file << "#{test_case.id},#{test_case.name}\n"
    ::ActionDispatch::Http::UploadedFile.new({
      filename: 'dadfas',
      content_type: 'text/plain',
      tempfile: file
    })
  end

  scenario "should render view upload_csv" do
    ready(test_run)
    sign_in member

    visit upload_csv_project_campaign_executions_path(project, campaign, test_run_id: test_run.id)
    expect(page.status_code).to eq(200)
  end

  scenario "User can upload *.csv file with correct file" do
    ready(test_run)
    sign_in member

    visit upload_csv_project_campaign_executions_path(project, campaign, test_run_id: test_run.id)
    attach_file 'datafile', uploaded_file.path
    find('form').click_button("Upload")
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq(accept_csv_project_campaign_executions_path(project, campaign))
  end
end

feature "PUT update" do
  let(:execution) { create(:execution) }
  let(:version) { execution.version }
  let(:test_run) { execution.test_run }
  let(:test_case) { execution.test_case }
  let(:campaign) { test_run.campaign }
  let(:project) { campaign.project }

  let(:member) do
    user = create(:user)
    project.add_member(user)
    user
  end

  before do
    test_run.update(executor: member)
    test_run.set_status_planned
    test_run.set_status_executing
  end

  scenario "User can update status of execution" do
    ready(test_run)
    sign_in member
    visit project_campaign_execution_path(project, campaign, execution)
    execution.reload.status.should eq('executing')
    fill_in 'execution_comment', with: 'Example comment'
    select 'passed', from: 'execution_status'
    find('form').click_button('Set result')
    expect(page.status_code).to eq(200)
    execution.reload.status.should eq('passed')
    expect(page.current_path).to eq(project_campaign_test_run_path(project, campaign, test_run))
  end

  scenario "User cannot update status of execution when didn't fill in comment field" do
    ready(test_run)
    sign_in member
    visit project_campaign_execution_path(project, campaign, execution)
    select 'passed', from: 'execution_status'
    find('form').click_button('Set result')
    page.should have_content('should have some text')
    page.should have_content('should have some file')
    execution.reload.status.should_not eq('passed')
    expect(page.current_path).to eq(project_campaign_execution_path(project, campaign, execution))
  end
end
