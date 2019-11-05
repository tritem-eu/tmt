module Tmt
  class TestCaseCustomField < ActiveRecord::Base

    include ::Tmt::CustomFieldConcern

    has_many :custom_field_values, class_name: "::Tmt::TestCaseCustomFieldValue", foreign_key: :custom_field_id
    has_one :enumeration, class_name: "::Tmt::Enumeration"

    # Return value for test case
    def value_for(test_case_id)
      custom_field_values.where(test_case_id: test_case_id).first.value
    rescue
      nil
    end

  end
end
