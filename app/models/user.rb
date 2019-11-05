class User < ActiveRecord::Base
  before_create :add_role_user

  belongs_to :current_project, class_name: "Tmt::Project"
  has_one :machine, class_name: 'Tmt::Machine'
  has_many :members, class_name: "Tmt::Member"
  has_many :projects, through: :members
  has_many :user_activities, class_name: "Tmt::UserActivity"

  validates_confirmation_of :password
  validates(:name,
    uniqueness: true
  )

  validate do
    validate_attribute_length :name, from: 2
  end

  validate do
    if not deleted_at.nil? and not deleted_at_was.nil?
      errors.add(:base, "You can update entry which was deleted")
    end
  end

  serialize :visited

  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :switch_password

  def self.admins
    admin_role = ::Role.where(name: :admin).first
    return [] unless admin_role
    admin_role.users
  end

  scope :undeleted, -> { where(deleted_at: nil) }

  def change_role(role_id)
    admin_id = ::Role.where(name: 'admin').first.id
    role_ids = (::Role.ids & [role_id.to_i])
    return false if role_ids.empty?
    if role_ids.include?(admin_id)
      self.update(role_ids: role_ids)
    else
      if ::UsersRole.where(role_id: admin_id).where.not(user_id: self.id).any?
        self.update(role_ids: role_ids)
      else
        false
      end
    end
  end

  def deleted?
    not self.deleted_at.nil?
  end

  def self.email_active?(email)
    users = where(email: email)
    if users.size > 0
      unless users[0].deleted?
        return true
      end
    end
    false
  end

  def self.common_project_ids_between(first_user, second_user)
    first_user.project_ids & second_user.project_ids
  end

  def machine?
    self.is_machine?
  end

  # return member with ids that same like self.id and project_id
  def member_for_project(project_or_id)
    entry = nil
    if project_or_id.class == Fixnum
      entry = members.where(project_id: project_or_id)
    else
      entry = members.where(project: project_or_id)
    end
    entry.first_or_create
  end

  def activities_recent_first
    self.user_activities.order(created_at: :desc).first(5)
  end

  # Method should store current user id
  # It is using by UserActivity model
  def self.updater_id=(id)
    @@updater_id = id
  end

  def self.updater_id
    @@updater_id
  rescue
    nil
  end

  def visited_project(project_id = nil)
    self.visited ||= {}
    if project_id.nil?
      self.visited[:project_id]
    else
      self.visited[:project_id] = project_id
      self.update(visited: self.visited)
      self.visited[:project_id]
    end
  end

  def admin?
    self.has_role?(:admin)
  end

  private

  # All new users have got role :user
  def add_role_user
    add_role :user
  end

end
