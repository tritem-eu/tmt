module Tmt
  module Tasks
    class Seed
      def self.sandbox
        admin = ::User.admins.first
        ::Tmt::Project.where(name: 'sandbox tests').first_or_create(creator_id: admin.id, description: "First use of the system in a real-world environment")

        [].each do |name, type_name, default_value, enum_values|
          if type_name == :enum
            enumeration = ::Tmt::Enumeration.where(name: name).first_or_create(default: default_value)
            enum_values.each_with_index do |text_value, index|
              enumeration.values.where(numerical_value: index, text_value: text_value).first_or_create
            end
            custom_fields = Tmt::TestRunCustomField.where(
              type_name: type_name,
              default_value: default_value,
              name: name
            ).first_or_create(enumeration_id: enumeration.id)
          else
            Tmt::TestRunCustomField.where(
              type_name: type_name,
              default_value: default_value,
              name: name
            ).first_or_create
          end
        end # each
      end
    end # Seed
  end
end
