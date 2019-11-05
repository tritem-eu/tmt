module Tmt
  class Cfg < ActiveRecord::Base

    before_destroy do
      false
    end

    validates :records_per_page, inclusion: {in: 1..100}, allow_blank: false

    validates :max_name_length, numericality: {greater_than_or_equal_to: 1}, allow_blank: false

    validates :file_size, numericality: {greater_than_or_equal_to: 0}

    validate do
      if self.id.nil?
        unless Tmt::Cfg.count == 0
          errors.add(:base, 'There can only be one')
        end
      end
    end

    def self.max_name_length
      Tmt::Cfg.first.max_name_length || 40
    rescue
      40
    end
  end
end
