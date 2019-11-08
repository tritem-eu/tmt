require 'spec_helper'

describe Tmt::HomeController do
  describe "GET 'index'" do
    let(:project) { create(:project) }
    let(:project_next) { create(:project) }
    let(:user) do
      user = create(:user)
      project.add_member(user)
      user
    end

    let(:admin) { create(:admin) }

    before do
      ready(project, project_next)
    end

    it "assigns one project for non-logged user" do
      get 'index'
      assigns(:projects).should be_empty
    end

    it "assigns one project for logged user" do
      sign_in user
      get 'index'
      assigns(:projects).should eq([project])
    end

    it "assigns two project for logged admin" do
      sign_in admin
      get 'index'
      assigns(:projects).should be_empty
    end
  end
end
