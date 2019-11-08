require 'spec_helper'

describe Tmt::TestRun do
  let(:test_run) { create(:test_run, campaign: campaign, executor: user) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:user_next) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:campaign) { create(:campaign) }
  let(:project) { campaign.project }
  let(:version) { build(:test_case_version, revision: "hash") }
  let(:version1) { build(:test_case_version, revision: "hash") }
  let(:version2) { build(:test_case_version, revision: "hash") }

  describe 'for name attribute' do
    it "can valid when length is correctly" do
      Tmt::Cfg.first.update(max_name_length: 20)
      build(:test_run, name: 'a'*15).should be_valid
    end

    it "cannot valid when length is uncorrectly" do
      Tmt::Cfg.first.update(max_name_length: 20)
      build(:test_run, name: 'a'*25).should_not be_valid
    end

    it "cannot be properly valid when name is empty" do
      build(:test_run, name: nil).should_not be_valid
    end
  end

  describe 'for due date attribute' do

    let(:time_now) { Time.parse('2013-03-13 15:31:59') }

    before do
      ready(time_now)
      Time.stub(:now) { time_now }
    end

    it "can valid when date is from future" do
      build(:test_run, due_date: time_now + 100).should be_valid
      create(:test_run, due_date: time_now + 100).due_date.should eq time_now + 100
    end

    it "set on current time when date is from now" do
      build(:test_run, due_date: time_now).should be_valid
    end

    it "can valid when content is empty" do
      build(:test_run, due_date: nil).should be_valid
    end

    it "set on current time when date is from past" do
      build(:test_run, due_date: time_now - 100).should be_valid
      test_run = create(:test_run, due_date: time_now - 100)
      test_run.due_date.to_s.first(10).should eq time_now.to_s.first(10)
    end

  end

  describe "for validation" do
    it "should create factory" do
      expect do
        create(:test_run)
      end.to_not raise_error
    end

    it "cannot be properly valid when creator is empty" do
      build(:test_run, creator: nil).should_not be_valid
    end

    it "cannot be properly valid when campaign is empty" do
      build(:test_run, campaign: nil).should_not be_valid
    end

    it "can't be properly valid when executor don't belong to project" do
      build(:test_run, executor: create(:user)).should_not be_valid
      expect do
        create(:test_run, executor: create(:user)).should_not be_valid
      end.to raise_error(/selected user doesn't belong to the current project/i)
    end

    it "should not edit record" do
      ready(test_run)
      expect do
        test_run.update(executor: nil)
      end.to_not raise_error
    end

    it "can valid attribute name" do
      Tmt::Cfg.first.update(max_name_length: 20)
      build(:test_run, name: 'a'*15).should be_valid
    end

    it "cannot valid attribute name" do
      Tmt::Cfg.first.update(max_name_length: 20)
      build(:test_run, name: 'a'*25).should_not be_valid
    end

  end

  describe "#update_log" do
    before do
      ready(test_run)
    end

    it "should create entry about changed name" do
      test_run.user_activities.should be_empty
      test_run.update(name: "New name")
      test_run.user_activities.should have(1).item
      test_run.user_activities.first.after_value.should eq("New name")
    end

    it "should create entry about changed status" do
      test_run.user_activities.should be_empty
      test_run.update(status: 2)
      test_run.user_activities.should have(1).item
      test_run.user_activities.first.after_value.should eq("planned")
    end

    it "should create entry about changed description" do
      test_run.user_activities.should be_empty
      test_run.update(description: "New description")
      test_run.user_activities.should have(1).item
      test_run.user_activities.first.after_value.should eq("New description")
    end

    it "should create entry about changed due date" do
      test_run.user_activities.should be_empty
      test_run.update(due_date: Time.now + 1.day)
      test_run.user_activities.should have(1).item
      time = test_run.due_date
      test_run.user_activities.first.after_value.first(10).should eq(time.to_s.first(10))
    end

    it "should create entry about changed executor" do
      test_run.user_activities.should be_empty
      test_run.update(executor_id: user_next.id)
      test_run.user_activities.should have(1).item
      time = test_run.due_date
      test_run.user_activities.first.after_value.should eq(user_next.name)
    end
  end

  describe "#clone_record" do
    let(:project) { create(:project) }
    let(:campaign) { create(:campaign, project_id: project.id) }
    let(:test_case) { create(:test_case, project: project)}
    let(:test_case_version) { create(:test_case_version, test_case_id: test_case.id) }
    let(:test_run) { create(:test_run,
      campaign_id: campaign.id,
      name: "Name 2014.08.07 11:39",
      description: "Description 2014.08.07 11:39",
      due_date: Time.now,
      creator_id: user.id,
      executor_id: user.id
    ) }

    it "should clone test run object" do
      ready(test_run)
      test_run.status = 2
      test_run.save(validate: false)
      test_run.reload.status.should eq 2
      cloned_test_run = test_run.clone_record
      cloned_test_run.id.should_not be_nil
      cloned_test_run.id.should_not eq test_run.id
      cloned_test_run.campaign_id.should eq campaign.id
      cloned_test_run.name.should eq "Name 2014.08.07 11:39"
      cloned_test_run.description.should eq "Description 2014.08.07 11:39"
      cloned_test_run.due_date.to_s.should eq test_run.due_date.to_s
      cloned_test_run.creator_id.should eq user.id
      cloned_test_run.executor_id.should eq user.id
      cloned_test_run.status.should eq 1
    end

    it "should clone test run which name is longer than current setting 'max name length' option" do
      ready(test_run)
      test_run.name.should eq('Name 2014.08.07 11:39')
      Tmt::Cfg.first.update(max_name_length: 2)
      expect do
        test_run.clone_record
      end.to change{Tmt::TestRun.count}.by(1)
    end

    it "should clone test run with open campaign" do
      ready(test_run)
      test_run.campaign.close
      campaign = create(:campaign, project: project)
      cloned_test_run = nil
      expect do
        cloned_test_run = test_run.clone_record
      end.to change{Tmt::TestRun.count}.by(1)
      cloned_test_run.campaign.should eq(campaign)
    end

    it "should not clone test run when project has not open campaign " do
      ready(test_run)
      test_run.campaign.close
      cloned_test_run = nil
      expect do
        cloned_test_run = test_run.clone_record
      end.to change{Tmt::TestRun.count}.by(0)
      cloned_test_run.should be_nil
    end

    it "should clone test run object and change author" do
      ready(test_run)
      creator = create(:user)
      project.add_member(creator)
      test_run.creator.should_not eq(creator)
      cloned_test_run = test_run.clone_record(creator: creator)
      cloned_test_run.id.should_not be_nil
      cloned_test_run.id.should_not eq test_run.id
      cloned_test_run.reload.creator.should eq(creator)
    end

    it "should clone versions of test run" do
      create(:execution)
      test_run.executions.create(version_id: test_case_version.id)
      create(:execution)

      cloned_test_run = test_run.clone_record
      cloned_test_run.executions.should have(1).item
      cloned_test_run.executions.first.version.should eq test_case_version
    end

    it "should clone custom fields of test run" do
      ready(test_run)
      enumeration = create(:enumeration_for_priorities)
      custom_field = create(:test_run_custom_field_for_enumeration,
        project: project,
        enumeration: enumeration
      )
      test_run.reload
      enumeration_value_id = enumeration.values.first.id
      test_run.custom_field_values.first.update(enum_value: enumeration_value_id)
      cloned_test_run = test_run.clone_record
      cloned_test_run.reload
      cloned_test_run.custom_field_values.should have(1).item
      cloned_test_run.custom_field_values.first.enum_value.should eq enumeration_value_id
      cloned_test_run.custom_field_values.first.id.should_not eq test_run.custom_field_values.first.id
    end

  end

  it "#push_versions" do
    ready(project)
    create(:test_case, project: project, versions: [version, version1])

    test_run.versions.should be_empty
    test_run.push_versions([version.id, version1.id])
    test_run.versions.reload.should have(2).items
    test_run.push_versions([version.id, version1.id])
    test_run.versions.reload.should have(4).items
  end

  it "should not push version from other projects" do
    ready(project)
    create(:test_case, project: project, versions: [version, version2])
    create(:test_case, project: create(:project), versions: [version1])

    test_run.push_versions([version.id, version1.id, version2.id])
    test_run.versions.should have(2).items
    test_run.versions.pluck(:version_id).should eq([version.id, version2.id])
  end

  describe "for custom fields attribute" do
    let(:category) do
      Tmt::TestRunCustomField.where(name: :category, type_name: :string).first_or_create(project_id: project.id)
    end

    let(:valid_attributes) do
      category_id = category.id
      {
        custom_field_values: {
          category_id => {
            'value' => "Example Category"
          }
        }
      }
    end

    it "should allowed set value for category with lower limit set 100" do
      ready(test_run)
      test_run.reload
      test_run.reload_custom_field_values
      test_run.update(valid_attributes)
      test_run.reload_custom_field_values
      test_run.update(valid_attributes)
      test_run.custom_field_values.pluck(:string_value).should include("Example Category")
    end

    it "should not allowed set value for category with lower limit set 100" do
      category.update(lower_limit: 100)
      test_run.reload_custom_field_values
      expect do
        test_run.update!(valid_attributes)
      end.to raise_error(/Custom Field Value class is incorrectly/)
    end

  end

  describe "#set_status_planned" do
    it "sets status on planned when status_name is seting on :new" do
      ready(test_run)
      create(:test_case, project: project, versions: [version, version2])
      test_run.push_versions([version.id, version1.id, version2.id])

      test_run.set_status_planned.should be true
      test_run.status_name.should eq(:planned)
    end

    it "doesn't set status on planned when one of test cases was deleted" do
      ready(test_run)
      test_case = create(:test_case, project: project, versions: [version, version2])
      test_case.set_deleted
      test_run.push_versions([version.id, version1.id, version2.id])

      test_run.set_status_planned.should be false
      test_run.status_name.should eq(:new)
    end

    it "doesn't set status on planned when status_name is seting on :planned" do
      ready(test_run)
      create(:test_case, project: project, versions: [version, version2])
      test_run.push_versions([version.id, version1.id, version2.id])
      test_run.stub(:status) { 2 }
      test_run.set_status_planned.should be false
      test_run.status_name.should eq(:planned)
    end

    it "doesn't set status on planned when executor isn't assigned" do
      ready(test_run)
      create(:test_case, project: project, versions: [version, version2])
      test_run.push_versions([version.id, version1.id, version2.id])
      test_run.stub(:executor) { nil }
      test_run.set_status_planned.should be false
      test_run.status_name.should eq(:new)
    end

    it "doesn't set status on planned when array of versions is empty" do
      ready(test_run)
      test_run.set_status_planned.should be false
      test_run.status_name.should eq(:new)
    end

  end

  it "should move its status to executing once any of the associated versions is in state executing, or above" do
    ready(project)
    create(:test_case, project: project, versions: [version])

    test_run.push_versions([version.id])
    test_run.set_status_planned
    ver = test_run.executions.first
    ver.update(status: :executing)

    test_run.save!
    test_run.status_name.should eq(:executing)
  end

  describe "test run in executing state" do
    before(:each) do
      ready(project)
      create(:test_case, project: project, versions: [version])

      test_run.push_versions([version.id])
      test_run.set_status_planned
      test_run.set_status_executing
    end

    it "should never allow moving back form status executing to planned" do
      test_run.set_status_planned
      test_run.status_name.should eq(:executing)
      test_run.set_status_new
      test_run.status_name.should eq(:executing)
    end

    it "should not allow adding versions to the test run when it's executing" do
      create(:test_case, project: project, versions: [version1])
      expect {
        test_run.push_versions([version1.id])
      }.to_not change(Tmt::Execution, :count)
    end
  end

  it "#set_deleted" do
    test_run.deleted_at.should be nil
    test_run.set_deleted
    test_run.deleted_at.should_not be nil
  end

  it ".undeleted" do
    test_runs = [
      create(:test_run, deleted_at: nil),
      create(:test_run, deleted_at: Time.now),
      create(:test_run, deleted_at: nil)
    ]
    Tmt::TestRun.undeleted.should match_array([test_runs[0], test_runs[2]])
  end

  it "#executions_status_counter" do
    ready(test_run)
    executions = [
      create(:execution, test_run: test_run),
      build(:execution, test_run: test_run, status: :passed).save(validate: false),
      build(:execution, test_run: test_run, status: :failed).save(validate: false),
      build(:execution, test_run: test_run, status: :failed).save(validate: false),
      build(:execution, test_run: test_run, status: :passed).save(validate: false),
      build(:execution, test_run: test_run, status: :passed).save(validate: false),
      build(:execution, test_run: test_run, status: :executing).save(validate: false),
      build(:execution, test_run: test_run, status: :error).save(validate: false),
    ]

    test_run.executions_statuses_counter.should eq({
      none: 1,
      passed: 3,
      error: 1,
      failed: 2,
      executing: 1
    })
  end

  describe "#terminate" do
    let(:user) { create(:user) }

    let(:other_user) { create(:user) }

    let(:project) do
      project = create(:project)
      project.add_member(user)
      project
    end

    let(:campaign) { create(:campaign, project: project) }

    let(:test_run) do
      create(:test_run,
        campaign: campaign,
        versions: [build(:test_case_version, revision: '12lkj42323092lk')],
        executor: user
      )
    end

    it "should not update record when test run has 'new' status" do
      test_run.terminate(other_user).should be false
      test_run.reload.has_status?(:new).should be true
    end

    it "should update record when test run has 'planned' status" do
      test_run.set_status_planned
      test_run.has_status?(:planned).should be true
      test_run.terminate(other_user).should be true
      test_run.reload.has_status?(:done).should be true
      execution = test_run.executions.first
      execution.status.should eq('error')
      execution.comment.should eq("The User with #{other_user.email} email terminated this execution.")
    end

    it "should update record when test run has 'executing' status" do
      test_run.set_status_planned
      test_run.has_status?(:planned).should be true
      test_run.terminate(other_user).should be true
      test_run.reload.has_status?(:done).should be true
      execution = test_run.executions.first
      execution.status.should eq('error')
      execution.comment.should eq("The User with #{other_user.email} email terminated this execution.")
    end

    it "should not update record when test run has 'done' status" do
      test_run.set_status_planned
      test_run.has_status?(:planned).should be true
      test_run.executions.first.update(status: 'passed', comment: 'The version was passed.')
      test_run.reload.has_status?(:done).should be true
      test_run.reload.terminate(other_user).should be false
      test_run.reload.has_status?(:done).should be true
      execution = test_run.executions.first
      execution.status.should eq('passed')
      execution.comment.should eq("The version was passed.")
    end
  end
end
