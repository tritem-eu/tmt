module CustomFieldHelper
  def custom_fields_path(custom_field)
    case custom_field.class.name.downcase
    when /run/
      admin_test_run_custom_fields_path(custom_field)
    when /case/
      admin_test_case_custom_fields_path(custom_field)
    else

    end
  end

  def custom_field_path(custom_field)
    case custom_field.class.name.downcase
    when /run/
      admin_test_run_custom_field_path(custom_field)
    when /case/
      admin_test_case_custom_field_path(custom_field)
    else

    end
  end

  def edit_custom_field_path(custom_field)
    case custom_field.class.name.downcase
    when /run/
      edit_admin_test_run_custom_field_path(custom_field)
    when /case/
      edit_admin_test_case_custom_field_path(custom_field)
    else

    end
  end

  def clone_custom_field_path(custom_field)
    case custom_field.class.name.downcase
    when /run/
      clone_admin_test_run_custom_field_path(custom_field)
    when /case/
      clone_admin_test_case_custom_field_path(custom_field)
    else

    end
  end

end
