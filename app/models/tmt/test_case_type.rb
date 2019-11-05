module Tmt
  class TestCaseType < ::ActiveRecord::Base

    has_many :test_cases, class_name: "Tmt::TestCase", foreign_key: :type_id
    belongs_to :project, class_name: "Tmt::Project", foreign_key: :default_type

    validates :name, {presence: true, uniqueness: true}

    validate do
      validate_attribute_length :name, from: 1
    end

    validate :validate_converter_attribute

    validate do
      if deleted_at_changed? and not deleted_at.nil? and not is_unused?
        errors.add(:deleted_at, "is used by some test case")
      end
    end

    scope :undeleted, -> { where(deleted_at: nil) }

    def is_unused?
      test_cases.empty?
    end

    # only unused can be deleted
    def set_deleted
      self.update(deleted_at: Time.now)
    end

    private

    def validate_converter_attribute
      return true if converter.blank?
      unless ::Tmt::Lib::Converter.list.include?(converter)
        self.errors.add(:converter, 'has got undefined converter')
      end
    end
  end
end
