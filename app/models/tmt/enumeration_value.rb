module Tmt
  class EnumerationValue < ActiveRecord::Base
    belongs_to :enumeration, class_name: "Tmt::Enumeration"

    before_destroy do
      unless enumeration.unassigned?
        errors.add(:base, "You cannot destroy it when some custom field using it")
        return false
      end
    end

    validates :numerical_value, {
      presence: true,
      uniqueness: { scope: :enumeration_id}
    }

    validates :text_value, {
      presence: true
    }

    validate do
      validate_attribute_length :text_value, from: 0
    end

    validate do
      unless enumeration and enumeration.unassigned?
        unless id.nil?
          unless numerical_value_was == numerical_value
            errors.add(:numerical_value, "cannot be changed when enumeration is used by some custom field")
          end
        end
      end
    end

  end
end
