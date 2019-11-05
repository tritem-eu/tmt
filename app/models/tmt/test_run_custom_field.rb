module Tmt
  class TestRunCustomField < ActiveRecord::Base

    include ::Tmt::CustomFieldConcern

    has_many :custom_field_values, class_name: "Tmt::TestRunCustomFieldValue", foreign_key: :custom_field_id
    has_one :enumeration, class_name: "Tmt::Enumeration"

    # Return value for test case
    def value_for(test_run_id)
      if self.type_name == :enum
        enid = Tmt::Enumeration.where(test_run_custom_field_id: self.id)
        Tmt::EnumerationValue.where(enumeration_id: enid, numerical_value: custom_field_values.where(test_run_id: test_run_id).first.value).take.text_value
      else
        custom_field_values.where(test_run_id: test_run_id).first.value
      end
    rescue
      nil
    end

  end
end
