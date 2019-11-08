require 'spec_helper'

describe '::Tmt::UserActivityPresenter' do
  class FakeController < ::ApplicationController
    extend ::ActionView::Helpers::TagHelper
    extend ::RailsExtras::Helpers::Tag
    include ::ActionView::Helpers::TagHelper
    include ::RailsExtras::Helpers::Tag
    include ::ActionView::Context
    include ::ApplicationHelper
    include ::ERB::Util
    include ::ActionView::Helpers::TranslationHelper
    include ::ActionView::Helpers::DateHelper

    def link_to(*args)
      add_tag { "(link)" }
    end

    def project_test_case_version_path(*args)
      'path'
    end
  end

  let(:fake_controller) {
    FakeController.new
  }

  let(:campaign) { create(:campaign) }

  let(:project) do
    project = campaign.project
    project.add_member(user)
    project
  end

  let(:user) { create(:user) }

  let(:test_case) { create(:test_case, project: project) }

  let(:test_run) { create(:test_run, campaign: campaign) }

  describe "#activity_for_observable" do
    it "when test case has changed name" do
      user_activity = create(:user_activity,
        project: project,
        user: user,
        observable: test_case,
        param_name: "Name",
        params: {parser: :custom_field},
        before_value: "Old name",
        after_value: "New name"
      )
      present = Tmt::UserActivityPresenter.new(user_activity, fake_controller)
      present.activity_for_user.should match(/changed.*Name.*from.*Old name.*to.*New name.*on Test Case \(link\).*less than a minute ago/)
    end

    it "when test run has changed name" do
      user_activity = create(:user_activity,
        project: project,
        user: user,
        observable: test_run,
        param_name: "Name",
        params: {parser: :custom_field},
        before_value: "Old name",
        after_value: "New name"
      )
      present = Tmt::UserActivityPresenter.new(user_activity, fake_controller)
      present.activity_for_user.should match(/changed.*Name.*from.*Old name.*to.*New name.*on Test run \(link\).*less than a minute ago/)
    end

    it "when test run was deleted" do
      user_activity = Tmt::UserActivity.save_for_deleted_observable(project, test_run, user)
      present = Tmt::UserActivityPresenter.new(user_activity, fake_controller)
      present.activity_for_user.should match(/removed.* Test run \(link\) .* less than a minute ago/)
    end

    it "when test case was deleted" do
      user_activity = Tmt::UserActivity.save_for_deleted_observable(project, test_case, user)
      present = Tmt::UserActivityPresenter.new(user_activity, fake_controller)
      present.activity_for_user.should match(/removed.* Test Case \(link\) .* less than a minute ago/)
    end

    it "when version was uploaded" do
      version = create(:test_case_version, test_case: test_case)
      user_activity = Tmt::UserActivity.save_for_version(project, test_case, user, version)
      present = Tmt::UserActivityPresenter.new(user_activity, fake_controller)
      present.activity_for_user.should match(/uploaded .*\(link\).* as a new version on Test Case \(link\).*less than a minute ago/)
    end

  end
end
