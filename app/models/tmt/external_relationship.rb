module Tmt
  class ExternalRelationship < ActiveRecord::Base
    belongs_to :source, polymorphic: true

    validates :source, {presence: true}
    validate :validate_attributes

    ATTR_URL = 'url'
    ATTR_RQ_ID = 'rq_id'

    def kind
      @kind ||= (self.url.blank? ? ATTR_RQ_ID : ATTR_URL)
    end

    def kind=(value)
      if value == ATTR_URL
        @kind = ATTR_URL
        self.rq_id = nil
      else
        @kind = ATTR_RQ_ID
        self.url = nil
        self.value = nil
      end
    end

    private

    def validate_attributes
      if kind == ATTR_RQ_ID
        test_cases = Tmt::TestCase.where(id: rq_id)
        if test_cases.empty?
          self.errors[:rq_id] << I18n.t(:rq_id, scope: [:models, :external_relationship])
          self.errors[:base] << I18n.t(:cannot_create_relationship_, scope: [:models, :external_relationship])
        end
      else
        unless url =~ URI::regexp(%w(http https))
          self.errors[:url] << I18n.t(:doesnt_match_the_pattern, scope: [:models, :external_relationship])
        end
      end
    end

  end
end
