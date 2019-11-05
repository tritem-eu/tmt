# Define abilities for the passed in user here. For example:
#
#   user ||= User.new # guest user (not logged in)
#   if user.admin?
#     can :manage, :all
#   else
#     can :read, :all
#   end
#
# The first argument to `can` is the action you are giving the user permission to do.
# If you pass :manage it will apply to every action. Other common actions here are
# :read, :create, :update and :destroy.
#
# The second argument is the resource the user can perform the action on. If you pass
# :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
#
# The third argument is an optional hash of conditions to further filter the objects.
# For example, here the user can only update published articles.
#
#   can :update, Article, :published => true
#
# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # guest user (not logged in)

    if @user.roles.empty?
      #can :read, :all #for guest without roles
    else
      @user.roles.each { |role| send(role.name.downcase) }
    end
  end

  def user
    can :script, ::User do |user|
      not user.id.nil?
    end

    can :read, Tmt::Project do
      not @user.id == nil
    end

    can :member, Tmt::Project do |project|
      @user.member_for_project(project).is_active == true
    end

    can :lead, Tmt::TestCase do |test_case|
      test_case.deleted_at.nil? and @user.member_for_project(test_case.project).is_active == true
    end

    can :no_lock, Tmt::TestCase do |test_case|
      test_case.steward_id.nil? or test_case.steward_id == @user.id
    end

    can :executor, Tmt::TestRun do |test_run|
      test_run.executor == @user
    end

    can :planned, Tmt::TestRun do |test_run|
      test_run.executor == @user and test_run.status == 2
    end

    can :executing, Tmt::TestRun do |test_run|
      test_run.executor == @user and test_run.status == 3
    end

    can :planned_or_executing, Tmt::TestRun do |test_run|
      test_run.executor == @user and [2, 3].include?(test_run.status)
    end

    can :editable, Tmt::TestRun do |test_run|
      test_run.status == 1 and test_run.campaign.is_open == true and test_run.deleted_at.nil? and test_run.project.users.include?(@user)
    end

    can :editable_for_oslc, Tmt::Execution do |execution|
      test_run = execution.test_run
      test_run.executor == @user and [2, 3, 4].include?(test_run.status) and test_run.deleted_at.nil?
    end

    can :read_for_oslc, Tmt::Execution do |execution|
      test_run = execution.test_run
      project = test_run.project
      @user.member_for_project(project).is_active == true and [2, 3, 4].include?(test_run.status) and test_run.deleted_at.nil?
    end

    can :is_open, Tmt::Campaign do |campaign|
      campaign.is_open
    end

    can :lead, Tmt::Set do |set|
      @user.member_for_project(set.project.id).is_active == true
    end

    can :destroy, Tmt::Set do |set|
      set.children.empty? and @user.member_for_project(set.project.id).is_active == true
    end

    can :read, Tmt::TestCaseType do
      not user.id.nil?
    end

    can :not_deleted, User do |user|
      user.deleted_at.nil?
    end

    can :read, User do |user|
      User.common_project_ids_between(@user, user).any?
    end
  end

  def admin
    user
    can :manage, Tmt::OslcCfg
    can :manage, Tmt::Cfg
    can :manage, Tmt::Enumeration
    can :manage, Tmt::EnumerationValue
    can :manage, Tmt::Execution
    can :manage, Tmt::ExternalRelationship
    can :manage, Tmt::Project
    can :manage, Tmt::Member
    can :manage, Tmt::Machine
    can :manage, Tmt::AutomationAdapter
    can :manage, Tmt::TestCase
    can :manage, Tmt::TestCaseCustomField
    can :manage, Tmt::TestCaseCustomFieldValue
    can :manage, Tmt::TestCaseVersion
    can :manage, Tmt::TestCasesSets
    can :manage, Tmt::TestRunCustomField
    can :manage, Tmt::TestRunCustomFieldValue
    can :manage, Tmt::CustomFieldType
    can :manage, Tmt::UserActivity

    can :read, User do
      true
    end
    can :list, User do
      true
    end

    can :index, User do
      true
    end

    can :update_role, User do
      true
    end

    can :create, User do
      true
    end

    can :update, User do
      true
    end

    can :destroy, User do
      true
    end

    can :lead, Tmt::Set do |set|
      true
    end

    can :lead, Tmt::TestCaseType do
      true
    end

    can :lead, Tmt::Enumeration do
      true
    end

    can :script, Tmt::Project do |project|
      true
    end

    can :lead, Tmt::Project do |project|
      true
    end

    can :lead, Tmt::Campaign do
      true
    end

    can :close, Tmt::Campaign do |campaign|
      campaign.test_runs.undeleted.all? { |test_run| test_run.status.to_i >= 4 }
    end

    can :edit, Tmt::Campaign do |campaign|
      campaign.is_open == true
    end

    can :terminate, Tmt::TestRun do |test_run|
      test_run.has_status?(:planned, :executing)
    end

  end
end
