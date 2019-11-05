module Tmt
  module CustomField

    # Set values for Test Case or Test Run
    def custom_field_values=(params)
      params.each do |key, value_attributes|
        custom_field_value = value_attributes[:value]
        value = nil
        self.custom_field_values.each do |custom_field_value|
          if key.to_i == custom_field_value.custom_field_id
            value = custom_field_value
          end
        end

        if value
          value.update(value: value_attributes[:value] || value_attributes['value'] )
        end
      end
    end

    def reload_custom_field_values(options={})
      custom_field_class = nil
      if self.class == Tmt::TestRun
        custom_field_class = Tmt::TestRunCustomField
      elsif self.class == Tmt::TestCase
        custom_field_class = Tmt::TestCaseCustomField
      end
      custom_fields = custom_field_class.select_for_project(project).undeleted

      custom_field_ids = custom_fields.pluck(:id)
      custom_field_value_ids = self.custom_field_values.pluck(:custom_field_id)
      to_remove = custom_field_value_ids - custom_field_ids
      self.custom_field_values.where(custom_field_id: to_remove).delete_all
      to_add = custom_field_ids - custom_field_value_ids
      to_add.each do |custom_field_id|
        begin
          value = options[custom_field_id.to_s]['value']
        rescue
          value = nil
        end
        self.custom_field_values.new(custom_field_id: custom_field_id, value: value)
      end
    end

  end
end
