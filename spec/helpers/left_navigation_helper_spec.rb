require 'spec_helper'

describe LeftNavigationHelper do
  let(:user) {
    create(:user)
  }

  let(:test_run) {
    create(:test_run, campaign: campaign, name: "Test Run 2014.08.05 12:39")
  }

  let(:test_case) {
    create(:test_case, project: project, name: "Test Case 2014.08.05 12:46")
  }

  let(:project) {
    project = create(:project)
    project.add_member(user)
    project
  }

  let(:campaign) {
    create(:campaign, project: project)
  }

  before do
    helper.stub(:current_user) { user }
  end

  context "#left_navigation_for_dashboard" do

    let(:content) { helper.left_navigation_for_dashboard(without_content_of_navigation: true)}

    it "has empty options" do
      content.should match(/Home/)
    end

    it "has current_user with current_project options" do
      helper.current_user.update(current_project: project)
      content.should match(/Home/)
      content.should match(/Dashboard/)
      content.should match(/Test Runs/)
      content.should match(/Test Cases/)
    end

    it "hasn't active dashboard when member is not active" do
      member = Tmt::Member.where(project: project, user: user).first_or_create
      member.update(is_active: false)
      helper.current_user.update(current_project: project)
      content.should match(/Home/)
      content.should_not match(/Dashboard/)
      content.should_not match(/Test Runs/)
      content.should_not match(/Test Cases/)
    end

    it "has current_test_run option" do
      member = Tmt::Member.where(project: project, user: user).first_or_create
      member.update(current_test_run_id: test_run.id)
      helper.current_user.update(current_project: project)
      content.should match(/Home/)
      content.should match(/Dashboard/)
      content.should match(/Test Runs/)
      content.should match(/Test Cases/)
      content.should match(/#{"Test Run 2014.08.05 12:39"}/)
    end

    it "has not got show current test case when it is deleted" do
      member = Tmt::Member.where(project: project, user: user).first_or_create
      member.update(current_test_run_id: test_run.id)
      test_run.update(deleted_at: Time.now)
      helper.current_user.update(current_project: project)
      content.should match(/Home/)
      content.should match(/Dashboard/)
      content.should match(/Test Runs/)
      content.should match(/Test Cases/)
      content.should_not match(/#{"Test Run 2014.08.05 12:39"}/)
    end

    it "has got current_test_case option" do
      member = Tmt::Member.where(project: project, user: user).first_or_create
      member.update(current_test_case_id: test_case.id)
      helper.current_user.update(current_project: project)
      content.should match(/Home/)
      content.should match(/Dashboard/)
      content.should match(/Test Runs/)
      content.should match(/Test Cases/)
      content.should match(/#{"Test Case 2014.08.05 12:46"}/)
    end

    it "has not got show current test case when it is deleted" do
      member = Tmt::Member.where(project: project, user: user).first_or_create
      member.update(current_test_case_id: test_case.id)
      test_case.update(deleted_at: Time.now)
      helper.current_user.update(current_project: project)
      content.should match(/Home/)
      content.should match(/Dashboard/)
      content.should match(/Test Runs/)
      content.should match(/Test Cases/)
      content.should_not match(/#{"Test Case 2014.08.05 12:46"}/)
    end
  end
end
