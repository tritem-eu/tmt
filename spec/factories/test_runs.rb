# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_run, class: "Tmt::TestRun" do
    association :campaign, factory: :campaign
    name "Name of test run"
    description "Description of test run"
    due_date Time.now - 1.day
    association :creator, factory: :user
    executor nil
  end

  factory :test_run_with_executor, class: "Tmt::TestRun" do
    association :campaign, factory: :campaign
    name "Name of test run"
    description "Description of test run"
    due_date Time.now - 1.day
    association :creator, factory: :user
    executor nil
    after(:create) do |test_run|
      creator = test_run.creator
      project = test_run.project
      project.add_member(creator)
      test_run.update(executor: creator)
    end
   #versions { [
   #  association(:test_case_version, revision: "hash"),
   #  association(:test_case_version, revision: "hash")
   #] }
  end

end
