class Tmt::TestCasesSets < ActiveRecord::Base
  belongs_to :test_case, class_name: "Tmt::TestCase"
  belongs_to :set

  validates :test_case, presence: true
  validates :set_id,
    presence: true,
    uniqueness: {scope: :test_case_id}

  validate :validate_project

  private

  # Raise the error when objects: set and test_case belong into another projects
  def validate_project
    if not set.nil? and not test_case.nil?
      unless set.project_id == test_case.project_id
        self.errors.add(:test_case_id, "Project isn't correct")
      end
    end
  end
end
