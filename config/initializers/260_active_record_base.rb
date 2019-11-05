class ActiveRecord::Base
  NAME_REGEX = /\A[[:word:]|[:ascii:]]*\z/

  def pasta(object, *arguments)
    arguments.each do |method|
      object = object.method(method).call
    end
    object
  rescue
    nil
  end

  def validate_attribute_length attribute, params={from: 1}
    max_name_length = ::Tmt::Cfg.max_name_length
    unless self[attribute].to_s.length.between?(params[:from], max_name_length)
      errors.add(attribute, I18n.t(:does_not_have_length_between_and, scope: [:models, :campaign], from: params[:from], to: max_name_length))
    end
  end

  def self.validates_by_name attribute, params={}
    @@validates_by_name_attribute = attribute
    self.validates attribute, {
      presence: true,
      format: {
        with: NAME_REGEX,
        message: "have to consist any of the following characters: a-z A-Z 0-9 _ - "
      }
    }.merge(params)

    self.validate do
      attribute = @@validates_by_name_attribute
      max_name_length = ::Tmt::Cfg.max_name_length
      unless self[attribute].to_s.length.between?(1, max_name_length)
        errors.add(attribute, I18n.t(:does_not_have_length_between_and, scope: [:models, :campaign], from: 1, to: max_name_length))
      end
    end
  end

end
