require_relative "../support/common"

FactoryGirl.define do
  factory :execution, class: "Tmt::Execution" do
    association :version, factory: :test_case_version
    association :test_run, factory: :test_run_with_executor

    factory :execution_for_executing do
      status :executing
    end

    factory :execution_for_passed do
      status :passed
      datafiles do
        [CommonHelper.uploaded_file('main_sequence_Report.html')]
      end
    end

    factory :execution_for_failed do
      status :failed
      datafiles do
        [CommonHelper.uploaded_file('main_sequence_Report.html')]
      end
    end

    factory :execution_with_short_report do
      status :passed
      datafiles do
        [CommonHelper.uploaded_file('short_report.html')]
      end
    end

  end
end
