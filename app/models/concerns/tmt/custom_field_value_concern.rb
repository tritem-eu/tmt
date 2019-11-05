module Tmt
  module CustomFieldValueConcern
    extend ActiveSupport::Concern
    included do

      if self.name == "Tmt::TestCaseCustomFieldValue"
        belongs_to :test_case, class_name: "Tmt::TestCase"
        belongs_to :custom_field, class_name: "Tmt::TestCaseCustomField", foreign_key: "custom_field_id"
        def enumeration
          ::Tmt::Enumeration.where(test_case_custom_field_id: custom_field.id).first
        end
      elsif self.name == "Tmt::TestRunCustomFieldValue"
        belongs_to :test_run, class_name: "Tmt::TestRun"
        belongs_to :custom_field, class_name: "Tmt::TestRunCustomField", foreign_key: "custom_field_id"

        def enumeration
          ::Tmt::Enumeration.where(test_run_custom_field_id: custom_field.id).first
        end
      end

      def custom_field_name
        self.custom_field.name
      end

      def self.type_names
        ::Tmt::CustomFieldType.type_names
      end

      def type_names
        ::Tmt::CustomFieldType.type_names
      end

      validate :bottom_limit, :top_limit

      # Return value of the given type
      def value
        type = custom_field.type_name
        case type.to_s.to_sym
        when :enum
          enumeration_value = ::Tmt::EnumerationValue.where(enumeration: enumeration, numerical_value: self.enum_value).first
          enumeration_value ? enumeration_value.text_value : nil
        when :date
          unless self.date_value.blank?
            Date.parse(self.date_value.to_s).to_s
          else
            nil
          end
        when :datetime
          unless self.date_value.blank?
            Date.parse(self.date_value.to_s).to_s
          else
            nil
          end
        else
          type_names.map { |type| self.send("#{type}_value") }.compact.last
        end
      end

      # Update value of type
      def value=(string)
        @value = string
        type = custom_field.type_name.to_s.to_sym
        if type_names.include?(type)
          type_names.map { |type| self.send("#{type}_value=", nil) }
          self.send("#{type}_value=", @value)
        else
          # raise error
        end
      end

      # return name of custom field type
      def type_name
        custom_field.type_name.to_sym
      end

      # return name of custom field
      def custom_field_name
        custom_field.name.to_sym
      end

      private

      def top_limit
        return true if self.value.nil?
        return true if custom_field.upper_limit.nil?
        case custom_field.type_name.to_s
        when 'int'
          if self.value > custom_field.upper_limit
            errors.add(:custom_field_id, "value is too high (maximum is #{custom_field.upper_limit})")
          else
            nil
          end
        when 'string'
          if self.value.length > custom_field.upper_limit
            errors.add(:custom_field_id, "string is too long (maximum is #{custom_field.upper_limit})")
          else
            nil
          end
        when 'text'
          if self.value.length > custom_field.upper_limit
            errors.add(:custom_field_id, "text is too long (maximum is #{custom_field.upper_limit})")
          else
            nil
          end
        end
      end

      def bottom_limit
        return true if self.value.nil?
        return true if custom_field.lower_limit.nil?
        case custom_field.type_name.to_s
        when 'int'
          if self.value < custom_field.lower_limit
            errors.add(:custom_field_id, "value is too low (minimum is #{custom_field.lower_limit})")
          else
            nil
          end
        when 'string'
          if self.value.length < custom_field.lower_limit
            errors.add(:custom_field_id, "string is too short (minimum is #{custom_field.lower_limit})")
          else
            nil
          end
        when 'text'
          if self.value.length < custom_field.lower_limit
            errors.add(:custom_field_id, "text is too short (minimum is #{custom_field.lower_limit})")
          else
            nil
          end
        end
      end

    end
  end
end
