module Tmt
  class CustomFieldPresenter < ApplicationPresenter
    presents :custom_field
    def button_to_new
      add_link send("new_admin_#{model_name}_custom_field_path"), class: "btn" do |content|
        content.space(icon('plus-sign'))
        content << h(t(:new_custom_field, scope: :custom_fields))
      end
    end

    def field_tag(custom_field_value, f)
      value = custom_field_value.value
      result = case custom_field_value.custom_field.type_name.to_s.to_sym
      when :string
        f.text_field(
          "#{custom_field.id}[value]",
          value: custom_field_value.value,
          class: "form-control"
          # placeholder: t(custom_field.name, scope: :test_cases)
        )
      when :int
        f.number_field(
          "#{custom_field.id}[value]",
          value: custom_field_value.value,
          class: "form-control"
          # placeholder: t(custom_field.name, scope: :test_cases)
        )
      when :bool
        add_tag do |tag|
          tag << f.hidden_field("#{custom_field.id}][value]", value: 'false')
          tag << f.check_box("#{custom_field.id}][value]", {class: "switch-small", checked: custom_field_value.value}, 'true', 'false')
        end
      when :date
        add_datetime({
          f: f,
          name: "#{custom_field.id}][value]",
          value: custom_field_value.value,
          type: :date
        })
      when :text
        f.text_area(
          "#{custom_field.id}][value]",
          value: value,
          class: "form-control no-resize-vertical"
          #placeholder: t(custom_field.name, scope: :test_cases)
        )
      when :enum
        f.select "#{custom_field.id}[value]", options_of_select(custom_field.enumeration.values, :numerical_value, :text_value, custom_field_value.enum_value), {}, {class: "form-control"}
      else

      end
      if custom_field_value.errors.any?
        add_tag(:span, class: 'control-group has-error') do |tag|
          tag << result
          tag << add_tag(:label, class: "help-inline text-danger") do
            custom_field_value.errors.first.last
          end
        end
      else
        result
      end
    end

    def disabled_project?
      not custom_field.project_id.nil?
    end

    def full_model_name
      t("#{model_name}_custom_fields", scope: :custom_fields)
    end

    def link_to_index
      link_to full_model_name, index_path
    end

    def link_delete
      link_delete(
        custom_field_path(custom_field),
        confirm: 'This action destroy all records which use this custom fields. This operation can take a few minutes! Are you sure?'
      )
    end

    def index_path
      send("admin_#{model_name}_custom_fields_path")
    end

    def model_name
      rise unless ["test_case", "test_run"].include?(params[:model_name].to_s)
      params[:model_name]
    end

    def show(attribute)
      result = custom_field.send(attribute)
      content_or_none(result)
    end

    def show_path
      send("admin_#{model_name}_custom_field_path", custom_field)
    end

  end
end
