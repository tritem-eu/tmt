require 'spec_helper'

describe Tmt::Set do
  let(:set) { create(:set) }

  let(:set_children) { create(:set, project: project, parent: set) }

  let(:set_no_parent) { create(:set, project: project) }

  let(:project) { set.project }

  it "should return list of children for Self" do
    ready(set)
    ready(set_children)
    set.children.should include(set_children)
  end

  it "should create when user" do
    expect do
      create(:set)
    end.to_not raise_error
  end

  it "shouldn't validate when name is empty" do
    build(:set, name: "", project: project).should_not be_valid
  end

  it "shouldn't validate when project is empty" do
    build(:set, project: nil).should_not be_valid
  end

  it "shouldn't validate when parent will be child" do
    set_root = create(:set, project: project)
    set_child = create(:set, project: project, parent: set_root)
    set_grandchild = create(:set, project: project, parent: set_child)
    expect do
      set_child.update!(parent_id: set_grandchild.id)
    end.to raise_error(ActiveRecord::RecordInvalid, /Parent You can not add posterity as parent/)
  end

  it "shouldn't validate when parent is itself" do
    set_root = create(:set, project: project)
    expect do
      set_root.update!(parent_id: set_root.id)
    end.to raise_error(ActiveRecord::RecordInvalid, /Parent You can not add posterity as parent/)
  end

  it "#posterity_ids" do
    ready(set, project)
    test_cases = []
    10.times do |item|
      test_cases[item] = create(:test_case, project: project)
    end
    set_child = set.children.create!(name: "children1", project: project)
    set_grandchild = set_child.children.create!(name: "grandchild", project: project)
    set_next_child = set.children.create!(name: "children2", project: project)

    set.posterity_ids.should eq([set.id, set_child.id, set_next_child.id, set_grandchild.id])
    set_child.posterity_ids.should eq([set_child.id, set_grandchild.id])
  end

  describe "complex situation" do
    before do
      ready(set, project)
      test_cases = []
      10.times do |item|
        test_cases[item] = create(:test_case, project: project)
      end
      set.test_cases << test_cases[0]
      set.test_cases << test_cases[1]

      @set_child = set.children.create!(name: "children1", project: project)
      @set_child.test_cases << test_cases[2]

      set_grandchild = @set_child.children.create!(name: "grandchild", project: project)
      set_grandchild.test_cases << test_cases[3]
      set_grandchild.test_cases << test_cases[4]

      set_next_child = set.children.create!(name: "children2", project: project)
      set_next_child.test_cases << test_cases[5]
      @test_cases = test_cases
    end

    it "#prsterity_test_cases_for" do
      set.posterity_test_cases_for(project).should eq([@test_cases[0], @test_cases[1], @test_cases[2], @test_cases[3], @test_cases[4], @test_cases[5]])
      @set_child.posterity_test_cases_for(project).should eq([@test_cases[2], @test_cases[3], @test_cases[4]])
    end

    it ".hash_tree" do
      tree = Tmt::Set.hash_tree(project)
      tree.keys.should match_array([:children, :id, :object, :test_cases])
      tree[:test_cases].should be_empty
      tree[:children].should have(1).item
      tree[:children].first[:id].should eq(set.id)
      tree[:children].first[:object].should eq(set)
      tree[:children].first[:test_cases].should match_array([@test_cases[0], @test_cases[1]])
      tree[:children].first[:children].should have(2).items
    end

  end

  context '#sets_for_select' do
    let(:color_project) { create(:project) }
    let(:green_set) { create(:set, project: color_project, name: 'green') }
    let(:blue_set) { create(:set, project: color_project, name: 'blue') }
    let(:darkblue_set) { create(:set, project: color_project, name: 'darkblue', parent: blue_set) }
    let(:sub_darkblue_set) { create(:set, project: color_project, name: 'sub_darkblue', parent: darkblue_set) }
    let(:lightblue_set) { create(:set, project: color_project, name: 'lightblue', parent: blue_set) }
    let(:sub_lightblue_set) { create(:set, project: color_project, name: 'sub_light_set', parent: lightblue_set) }
    let(:red_set) { create(:set, name: 'red', project: color_project) }
    let(:darkred_set) { create(:set, project: color_project, name: 'darkred', parent: red_set) }

    before do
      ready(green_set,
        blue_set,
        darkblue_set,
        sub_darkblue_set,
        lightblue_set,
        sub_lightblue_set,
        red_set,
        darkred_set
      )
    end

    it "should select sets for set with parent" do
      darkblue_set.sets_for_select.should match_array([red_set, green_set, blue_set, lightblue_set])
    end

    it "should select sets for set without parent" do
      blue_set.sets_for_select.should match_array([red_set, green_set])
    end

    it "should select sets with ancestors in a straight line" do
      sub_lightblue_set.sets_for_select.should match_array([blue_set, lightblue_set, darkblue_set])
    end


  end
end
