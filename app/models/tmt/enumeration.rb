module Tmt
  class Enumeration < ActiveRecord::Base
    has_many :values, class_name: "Tmt::EnumerationValue"
    belongs_to :test_case_custom_field, class_name: "Tmt::TestCaseCustomField"
    belongs_to :test_run_custom_field, class_name: "Tmt::TestRunCustomField"

    validates_by_name :name
    scope :unassigned, -> { where(test_case_custom_field_id: nil, test_run_custom_field_id: nil) }

    def unassigned?
      self.test_case_custom_field.nil? && self.test_run_custom_field.nil?
    end

    def first_free_int_value
      return 0 if self.values.empty?
      self.values.maximum(:numerical_value) + 1
    end

    def related_custom_field
      if !unassigned?
        if test_run_custom_field.nil?
          test_case_custom_field
        else
          test_run_custom_field
        end
      end
    end
  end
end
