require 'spec_helper'

feature "Tmt::TestCasesSets" do

  let(:project) { create(:project) }
  let(:campaign) { create(:campaign, project: project) }
  let(:test_run) { create(:test_run, campaign: campaign) }
  let(:set) { create(:set, name: "Old Set", project: project) }

  let(:test_case) { create(:test_case, project: project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  scenario "should create new TestCasesSet" do
    ready(set)
    ready(test_case)
    sign_in user
    visit new_project_test_cases_set_path(project, set_id: set.id)
    expect do
      within '.form-horizontal' do
        select(find("option[value='#{test_case.id}']").text)
        click_button ""
      end
    end.to change(Tmt::TestCasesSets, :count).by(1)
  end
end
