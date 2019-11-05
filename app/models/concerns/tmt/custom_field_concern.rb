module Tmt
  module CustomFieldConcern
    extend ActiveSupport::Concern
    included do
      belongs_to :project, class_name: "Tmt::Project"
      scope :undeleted, -> { where(deleted_at: nil).order(created_at: :desc) }

      validates :name, presence: true, format: {
        with: /\A[[:alpha:]0-9_-]+\Z/,
        message: "have to consist any of the following characters: a-z A-Z 0-9 _ - "
      }
      validate do
        validate_attribute_length :name, from: 1
      end
      validates :type_name, presence: true
      validate :validate_default_value
      validate :validate_enumeration_id
      validate :validate_lower_limit
      validate :validate_upper_limit
      validate :validate_type_name
      validate :only_one_type_to_choose

      validate do
        if project_id == project_id_was or project_id_was.blank?
        else
          errors.add(:project_id, "can not be changed on other project.")
        end
        unless project_id.nil?
          if Tmt::Project.where(id: project_id).empty?
            errors.add(:project_id, "doesn't exist in database")
          end
        end
      end

      after_destroy do
        if not project.nil?
          if self.kind_of?(Tmt::TestRunCustomField)
            Tmt::TestRunCustomFieldValue.where(custom_field_id: self.id).destroy_all
          elsif self.kind_of?(Tmt::TestCaseCustomField)
            Tmt::TestCaseCustomFieldValue.where(custom_field_id: self.id).destroy_all
          else
            raise "#{self.class} is not defined for after_destroy method"
          end
        end
      end

      # should create values for custom field
      after_save do
        if not project.nil?
          if self.kind_of?(Tmt::TestRunCustomField)
            test_run_ids = project.test_runs.pluck(:id)
            test_run_ids.each do |test_run_id|
              Tmt::TestRunCustomFieldValue.where(test_run_id: test_run_id, custom_field_id: self.id).first_or_create
            end
          elsif self.kind_of?(Tmt::TestCaseCustomField)
            test_case_ids = project.test_cases.pluck(:id)
            test_case_ids.each do |test_case_id|
              Tmt::TestCaseCustomFieldValue.where(test_case_id: test_case_id, custom_field_id: self.id).first_or_create
            end
          else
            raise "#{self.class} is not defined for after_save method"
          end
        end
      end

      # Return array of custom fields assigned for project
      def self.select_for_project(project_or_id = nil)
        project_id = project_or_id
        if project_or_id.class == ::Tmt::Project
          project_id = project_or_id.id
        end
        self.where(project_id: project_id).order(created_at: :desc)
      end

      def self.type_names
        ::Tmt::CustomFieldType.type_names
      end

      def type_names
        ::Tmt::CustomFieldType.type_names
      end

      def enumeration_id
        self.enumeration.id unless enumeration.nil?
      end

      def enumeration_id=(id)
        if self.type_name.to_s == 'enum'
          begin
            self.enumeration = ::Tmt::Enumeration.find(id)
          rescue
            nil
          end
        else
          #do nothing
        end
      end

      def enumeration_not_selected
        ::Tmt::Enumeration.where(test_case_custom_field_id: nil, test_run_custom_field_id: nil)
      end

      def generate_duplicate
        result = self.dup
        if 'enum' == self.type_name.to_s and not self.enumeration.nil?
          initialized_enumeration = Enumeration.where(
            test_run_custom_field_id: nil,
            test_case_custom_field_id: nil,
            name: self.enumeration.name
          ).first_or_initialize
          result.enumeration = initialized_enumeration
          old_attributes = initialized_enumeration.values.map{ |item| [item.numerical_value, item.text_value]}
          unless enumerations_are_similar?(initialized_enumeration, self.enumeration)
            self.enumeration.values.each do |value|
              new_value = value.dup
              new_value.enumeration_id = nil
              unless old_attributes.include?([value.numerical_value, value.text_value])
                initialized_enumeration.values << new_value
              end
            end
            initialized_enumeration.save
          end
        end
        result.project_id = nil
        result
      end

      def save_deleted
        self.deleted_at = Time.now
        self.save
      end

      private

      # return true when two enumerations have the same values
      def enumerations_are_similar?(first_enumeration, second_enumeration)
        first_array = first_enumeration.values.select([:numerical_value, :text_value])
        second_array = second_enumeration.values.select([:numerical_value, :text_value])
        return false unless first_array.size == second_array.size
        (first_array - second_array).empty?
      end

      def validate_default_value
        return true if self.default_value.blank?
        case type_name.to_s
        when 'int'
          unless self.default_value.to_s =~ /\A(-|)[0-9]*\Z/
            self.errors.add(:default_value, "is not number")
          end
        when 'string', 'text'
        when 'enum'
          unless self.enumeration.values.ids.include?(self.default_value.to_i)
            self.errors.add(:default_value, 'used undefined enumeration')
          end
        when 'date'
          begin
            self.default_value = Date.parse(self.default_value).to_s
          rescue
            self.errors.add(:default_value, "is not date")
          end
        when 'datetime'
          begin
            self.default_value = Time.parse(self.default_value).to_s
          rescue
            self.errors.add(:default_value, "is not datetime (YYYY-MM-DD HH:ii)")
          end
        when 'bool'
          begin
            self.default_value.to_s.to_bool
            true
          rescue
            self.errors.add(:default_value, 'is not boolean value')
          end
        else
          self.errors.add(:base, 'type name is not defined.')
        end
      end

      def validate_upper_limit
        return true if upper_limit.blank?
        case type_name.to_s
        when 'int'
          unless upper_limit.to_s =~ /\A(-|)[0-9]*\Z/
            self.errors.add(:upper_limit, "is not correctly defined")
          end
        when 'string', 'text'
          unless upper_limit.to_s =~ /\A[0-9]*\Z/
            self.errors.add(:upper_limit, "is not natural number")
          end
        else
          self.errors.add(:upper_limit, "should be blank")
        end
      end


      def validate_lower_limit
        return true if lower_limit.blank?
        case type_name.to_s
        when 'int'
          unless lower_limit.to_s =~ /\A(-|)[0-9]*\Z/
            self.errors.add(:lower_limit, "is not correctly defined")
          end
        when 'string', 'text'
          unless lower_limit.to_s =~ /\A[0-9]*\Z/
            self.errors.add(:lower_limit, "is not natural number")
          end
        else
          self.errors.add(:lower_limit, "should be blank")
        end
      end

      def validate_enumeration_id
        if type_name.to_s == 'enum'
          if self.id.nil?
            if self.enumeration_id.nil?
              self.errors.add(:enumeration_id, "doesn't exist")
            else
              unless self.enumeration_not_selected.pluck(:id).include?(enumeration_id)
                self.errors.add(:enumeration_id, "was used by other object")
              end
            end
          else
            # controller shouldn't change this attribute
          end
        else
          unless enumeration_id.blank?
            self.errors.add(:enumeration_id, "enumeration should be empty")
          end
        end
      end

      def validate_type_name
        unless type_names.map(&:to_s).include?(type_name.to_s)
          errors.add(:type_name, "doesn't include element from defined list")
        end
      end

      def only_one_type_to_choose
        unless self.id.nil?
          if type_name_changed?
            errors.add(:type, "You can't change type")
          end
        end
      end

    end
  end
end
