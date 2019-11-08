require 'spec_helper'

describe Admin::OslcCfgsController do
  extend ::CanCanHelper

  let(:valid_attributes) { { "instance_name" => "MyString" } }

  let(:test_case_type_without_file) { create(:test_case_type)}
  let(:test_case_type_with_file) { create(:test_case_type, has_file: true)}

  let(:admin) { create(:admin) }

  let(:oslc_cfg) { Tmt::OslcCfg.cfg }

  before do
    ready(oslc_cfg)
  end

  describe "GET index" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index
    end

    it "assigns the cfg as @cfg" do
      sign_in admin

      get :index
      assigns(:oslc_cfg).should eq(oslc_cfg)
    end
  end

  describe "PUT update" do

    before do
      ready(test_case_type_with_file, test_case_type_without_file)
    end

    describe "with valid params" do

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        put :update, {id: oslc_cfg.id, oslc_cfg: {test_case_type_id: test_case_type_with_file.id}}
      end

      it "updates the requested cfg" do
        sign_in admin
        Tmt::OslcCfg.any_instance.should_receive(:update).with({"test_case_type_id" => test_case_type_with_file.id.to_s })
        put :update, {id: oslc_cfg.id, oslc_cfg: {test_case_type_id: test_case_type_with_file.id}}
      end

      it "assigns the requested cfg as @oslc_cfg" do
        sign_in admin
        put :update, {id: oslc_cfg.id, oslc_cfg: {test_case_type_id: test_case_type_with_file.id}}
        assigns(:oslc_cfg).should eq(oslc_cfg)
      end

      it "redirects to the oslc-cfg" do
        sign_in admin
        put :update, {id: oslc_cfg.id, oslc_cfg: {test_case_type_id: test_case_type_with_file.id}}
        response.should redirect_to(admin_oslc_cfgs_url)
      end
    end

    describe "with invalid params" do
      it "assigns the cfg as @cfg" do
        sign_in admin
        Tmt::Cfg.any_instance.stub(:save).and_return(false)
        put :update, {id: oslc_cfg.id, oslc_cfg: {test_case_type_id: 0}}
        assigns(:oslc_cfg).should eq(oslc_cfg)
      end

      it "re-renders the 'index' template" do
        sign_in admin
        Tmt::Cfg.any_instance.stub(:save).and_return(false)
        put :update, {id: oslc_cfg.id, oslc_cfg: {test_case_type_id: 0}}
        response.should render_template("index")
      end
    end
  end

end
