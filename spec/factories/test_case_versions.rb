require_relative "../support/common"

FactoryGirl.define do
  factory :test_case_version, class: "Tmt::TestCaseVersion" do
    association :test_case, factory: :test_case_with_type_file
    association :author, factory: :user
    comment "Comment"

    datafile { |item|
      ::CommonHelper.uploaded_file('test_case_version')
    }

    factory :test_case_version_with_revision do
      revision "566eb95ce5a180232dd55969bcd8cfa9eb852dd1"
      comment "git commit"
      sequence(:datafile) { |item| "#{item}. Example body of file."}
    end
  end
end
