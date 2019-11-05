class Tmt::OslcCfg < ActiveRecord::Base

  belongs_to :test_case_type, class_name: "::Tmt::TestCaseType"

  before_destroy do
    false
  end

  # create new entry or get existing
  def self.cfg
    ::Tmt::OslcCfg.first_or_create(test_case_type_id: 1)
  end

  private

  validate do
    if self.id.nil?
      unless Tmt::OslcCfg.count == 0
        errors.add(:base, 'There can only be one')
      end
    end
  end

  validate do
    if test_case_type_id.blank?
      errors.add(:test_case_type_id, "can't be blank")
    else
      unless ::Tmt::TestCaseType.ids.include?(test_case_type_id)
        errors.add(:test_case_type_id, "doesn't use defined type")
      end
    end
  end

end
