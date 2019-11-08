# Read about factories at https://github.com/thoughtbot/factory_girl

[
  ["Tmt::TestCaseCustomField", :test_case],
  ["Tmt::TestRunCustomField", :test_run]
].each do |class_name, prefix|
  FactoryGirl.define do
    factory "#{prefix}_custom_field", class: class_name do
      name "MyString"
      description "MyText"
      type_name :string
      upper_limit 100
      lower_limit 0
      association :project, factory: :project
      default_value "MyText"
    end

    factory "#{prefix}_custom_field_for_string", class: class_name do
      name "String"
      description "String"
      type_name :string
      upper_limit 100
      lower_limit 0
      default_value "String"
    end

    factory "#{prefix}_custom_field_for_integer", class: class_name do
      name "Range"
      description "Range"
      type_name :int
      upper_limit 100
      lower_limit -10
      default_value 3
    end

    factory "#{prefix}_custom_field_for_text", class: class_name do
      name "Description"
      description "Description"
      type_name :text
      upper_limit 100
      lower_limit 10
      default_value 'Description text'
    end

    factory "#{prefix}_custom_field_for_enumeration", class: class_name do
      name "CustomFieldwithEnumeration"
      description "Description of Custom field with Enumeration"
      association :project, factory: :project
      type_name :enum
      association :enumeration, factory: :enumeration_for_priorities
    end

    factory "#{prefix}_custom_field_for_date", class: class_name do
      name "date"
      description "Date"
      type_name :date
      association :project, factory: :project
      default_value '2014-06-23'
    end

    factory "#{prefix}_custom_field_for_bool", class: class_name do
      name "Bool"
      description "Bool"
      type_name :bool
      association :project, factory: :project
      default_value false
    end

  end
end
