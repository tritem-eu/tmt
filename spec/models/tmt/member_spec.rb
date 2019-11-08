require 'spec_helper'

describe Tmt::Member do

  let(:user) { create(:user) }

  let(:project_tmt) { create(:project) }

  let(:member) do
    create(:member, project_id: project_tmt.id, user_id: user.id, is_active: true)
  end

  it "should properly valid record" do
    build(:member).should be_valid
  end

  it "shouldn't properly valid record without empty user" do
    build(:member, user_id: nil).should_not be_valid
  end

  it "shouldn't properly valid record without empty project" do
    build(:member, project_id: nil).should_not be_valid
  end

  it "should return hash with id of user and object ProjectMember" do
    ready(member)
    Tmt::Member.members_with_objects(project_tmt.id).should include(user.id => member)
  end

  it "shouldn't duplication of data" do
    create(:member, project_id: project_tmt.id, user_id: user.id)
    expect do
      create(:member, project_id: project_tmt.id, user_id: user.id)
    end.to raise_error(ActiveRecord::RecordInvalid, /The user and project should be unique/)
  end

  it "should has got setted is_active attribute on false as the default value" do
    member = create(:member, project_id: project_tmt.id, user_id: user.id)
    member.is_active.should be false
  end

  describe "#update_set_ids" do
    let(:member) { create(:member) }
    let(:project) { member.project }

    let(:set) { create(:set, project: project) }
    let(:set_child) { create(:set, parent_id: set.id, project: project) }
    let(:set_grandchild) { create(:set, parent_id: set_child.id, project: project) }
    let(:set_foreign) { create(:set) }

    before do
      ready(set, set_child, set_grandchild, set_foreign)
    end

    it "should add new set_id to empty array" do
      options = {add_set_id: set.id.to_s}
      member.set_ids.should be_nil
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should match_array([set.id.to_s])
    end

    it "should add new set_id to existing array" do
      options = {add_set_id: set_child.id.to_s}
      member.update(set_ids: [set.id.to_s])
      member.set_ids.should have(1).item
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should match_array([set.id.to_s, set_child.id.to_s])
    end

    it "should not add foreign set" do
      options = {add_set_id: set_foreign.id.to_s}
      member.update(set_ids: [set.id.to_s])
      member.set_ids.should have(1).item
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should match_array([set.id.to_s])
    end

    it "should add set_id with posterity ids" do
      options = {add_set_id: set.id.to_s, with_posterity: '1'}
      member.set_ids.should be_nil
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should match_array([set.id.to_s, set_child.id.to_s, set_grandchild.id.to_s])
    end

    it "should remove set_id from empty array" do
      options = {remove_set_id: set.id.to_s}
      member.set_ids.should be_nil
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should be_empty
    end

    it "should remove set_id to existing array" do
      options = {remove_set_id: set.id.to_s}
      member.update(set_ids: [set.id.to_s])
      member.set_ids.should have(1).item
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should be_empty
    end

    it "should not remove foreign set" do
      options = {remove_set_id: set_foreign.id.to_s}
      member.update(set_ids: [set.id.to_s])
      member.set_ids.should have(1).item
      member.updated_set_ids([set, set_child, set_grandchild], options)
      member.set_ids.should match_array([set.id.to_s])
    end


  end
end
