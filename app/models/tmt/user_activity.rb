class Tmt::UserActivity < ActiveRecord::Base
  before_save do
    self.before_value = self.before_value.to_s.first(255)
    self.after_value = self.after_value.to_s.first(255)
  end

  belongs_to :observable, polymorphic: :true
  belongs_to :user
  belongs_to :project

  validates :param_name, presence: true
  validates :project_id, presence: true
  serialize :params

  def self.save_for_version(project, test_case, user, version)
    Tmt::UserActivity.create(
      user_id: user.id,
      observable: test_case,
      param_name: 'Version', # a constant that identifies activity entry as a version change indication
      params: {
        parser: :uploaded_version,
        version_id: version.id,
        file_name: Base64.encode64(version.file_name)
      },
      project: project
    )
  end

  def self.save_for_deleted_observable(project, observable, user)
    Tmt::UserActivity.create(
      user_id: user.id,
      observable: observable,
      param_name: 'Deleted',
      params: {
        parser: :deleted_observable
      },
      project: project
    )
  end
end
