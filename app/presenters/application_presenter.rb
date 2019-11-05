class ApplicationPresenter < BasePresenter

  def header_name(translate=nil)
    result = if translate.nil?
      translate = @object.class.name.scan(/[A-Z][a-z]+/).join(" ")
      translate.gsub!("Tmt ", "")
    else
      translate
    end

    result || ''
  end

  def subject_name(attr_name=:name)
    if @object.id
      if params[:action].to_sym == :edit
          " Edit #{@object.send(attr_name)}"
      else
        " #{@object.send(attr_name)} "
      end
    else
      " New"
    end
  end

  def button_to_edit
    link_edit edit_object_path
  end

  def edit_object_path
    send("edit_#{@object.class.name.gsub('Tmt::', '').underscore}_path", @object.id)
  end

  def delete_object_path
    send("#{@object.class.name.gsub('Tmt::', '').underscore}_path", @object.id)
  end

  private

  def content_or_none(content=nil)
    unless content.blank?
      content
    else
      add_tag(:i, "- None -", class: 'text-muted')
    end
  end


end
