require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "changeme",
      :password_confirmation => "changeme"
    }
    Tmt::Cfg.first.update(max_name_length: 35)
  end

  let(:user) {
    create(:user, @attr)
  }

  let(:project) { create(:project) }

  let(:member) do
    create(:member, project_id: project.id, user_id: user.id)
  end

  let(:admin) { create(:admin) }

  it "should create a new instance given a valid attribute" do
    User.create!(@attr)
  end

  describe '.validates' do
    it "should not create record when length of name is greater than 35" do
      expect do
        create(:user, name: 'a'*36)
      end.to raise_error(ActiveRecord::RecordInvalid, /does not have length between 2 and 35/)
    end

    it "should create record when length of name is lower than 36" do
      expect do
        create(:user, name: 'a'*35)
      end.to change(User, :count).by(1)
    end
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = User.new(@attr)
    end

    it "should have a password attribute" do
      @user.should respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end

  end

  it "should create default role :usera" do
    user.has_role?(:user).should be true
  end

  describe "#member_for_project" do
    before do
      member
    end

    it "for imaginary project" do
      user.member_for_project(0).should be_a(::Tmt::Member)
    end

    it "for existing project.id" do
      user.member_for_project(project.id).should eq(member)
    end

    it "for existing project" do
      user.member_for_project(project).should eq(member)
    end

  end

  it ".admins" do
    ready(admin, user)
    User.admins.should eq([admin])
  end

  describe '#change_rolies' do
    let(:role_admin_id) { ::Role.where(name: 'admin').first.id }

    it "when only one user has admin role" do
      ready(admin, user)
      ::UsersRole.where(role_id: role_admin_id).should have(1).item
      admin.change_role(nil).should be false
      ::UsersRole.where(role_id: role_admin_id).should have(1).item
    end

    it "when two users have admin role" do
      ready(admin, create(:admin))
      ::UsersRole.where(role_id: role_admin_id).should have(2).item
      admin.change_role(nil).should be false
      ::UsersRole.where(role_id: role_admin_id).should have(2).item
    end

    it "should not set a nonexistent role" do
      ready(admin, user)
      ::UsersRole.all.should have(3).item
      admin.change_role('0').should be false
      ::UsersRole.all.map(&:role_id).should_not include(0)
      ::UsersRole.all.should have(3).item
    end
  end
  
end
