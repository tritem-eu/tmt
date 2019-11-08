require 'spec_helper'

feature "Tmt::Sets" do
  let(:project) { set.project }

  let(:set) { create(:set, name: "Old Set") }
  let(:set_parallel) { create(:set, project: project) }

  let(:test_case) { create(:test_case, project: project) }
  let(:set1) { create(:set, project: project, parent: set) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  context "New set" do
    scenario "should create set" do
      ready(set)
      sign_in user
      visit new_project_set_path(project, parent_id: set.id)
      within '#new_set' do
        fill_in 'set_name', with: 'Example new set'
        click_button ""
      end
      new_set = Tmt::Set.where(name: "Example new set").first
      new_set.should_not be_nil
      new_set.parent.should eq(set)
    end

    scenario "should render new template for format js" do
      ready(set)
      sign_in user
      visit new_project_set_path(project, format: :js)
      expect(page.status_code).to eq(200)
    end
  end

  context "Edit set" do
    scenario "should update Set" do
      ready(set, set_parallel, set1)
      sign_in user
      visit edit_project_set_path(project, set)
      within '#edit_set' do
        fill_in 'set_name', with: 'Example update set'
        find("option[value='#{set_parallel.id}']").select_option
        click_button ""
      end
      new_set = Tmt::Set.where(name: "Example update set").first
      new_set.should_not be_nil
      new_set.parent.should eq(set_parallel)
    end

    scenario "should render edit template for format js" do
      ready(set)
      sign_in user
      visit edit_project_set_path(project, set, format: :js)
      expect(page.status_code).to eq(200)
    end
  end

  context "Index page" do
    scenario "should visit index view" do
      ready(set, set1)
      sign_in user
      visit project_sets_path(project)
      expect(page.current_path).to eq(project_sets_path(project))
    end

    scenario "should visit index view" do
      ready(set, set1)
      sign_in user
      visit project_sets_path(project)
      expect(page.current_path).to eq(project_sets_path(project))
    end

  end
end
