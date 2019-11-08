require 'spec_helper'

describe Admin::CfgsController do
  extend ::CanCanHelper

  let(:valid_attributes) { { "instance_name" => "MyString" } }

  let(:admin) { create(:admin) }

  let(:cfg) { Tmt::Cfg.first }

  before do
    ready(cfg)
  end

  describe "GET index" do
    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :index
    end

    it "assigns the cfg as @cfg" do
      sign_in admin

      get :index
      assigns(:cfg).should eq(cfg)
    end
  end

  describe "PUT update" do
    describe "with valid params" do

      it_should_not_authorize(self, [:no_logged, :foreign]) do
        put :update, {:id => cfg.to_param, :cfg => { "instance_name" => "MyString" }}
      end

      it "updates the requested cfg" do
        sign_in admin
        Tmt::Cfg.any_instance.should_receive(:update).with({ "instance_name" => "MyString" })
        put :update, {:id => cfg.to_param, :cfg => { "instance_name" => "MyString" }}
      end

      it "assigns the requested cfg as @cfg" do
        sign_in admin
        put :update, {:id => cfg.to_param, :cfg => valid_attributes}
        assigns(:cfg).should eq(cfg)
      end

      it "redirects to the cfg" do
        sign_in admin
        put :update, {:id => cfg.to_param, :cfg => valid_attributes}
        response.should redirect_to(admin_cfgs_url)
      end

      describe "for time_zone" do
        it "default should be warsaw" do
          sign_in admin
          put :update, {:id => cfg.to_param, :cfg => valid_attributes}
          cfg.reload.time_zone.should be nil
        end

        it "default should be warsaw" do
          sign_in admin
          put :update, {:id => cfg.to_param, :cfg => valid_attributes.merge(time_zone: 'Pacific Time (US & Canada)')}
          cfg.reload.time_zone.should eq 'Pacific Time (US & Canada)'
        end

        it "should change records_per_page attribute" do
          sign_in admin
          cfg.records_per_page.should_not eq(13)
          put :update, {:id => cfg.to_param, :cfg => valid_attributes.merge(records_per_page: 13)}
          cfg.reload.records_per_page.should eq(13)
        end

        it "should not change records_per_page attribute when value equal -1" do
          sign_in admin
          cfg.update(records_per_page: 10).should be true
          put :update, {id: cfg.to_param, :cfg => valid_attributes.merge(records_per_page: -1)}
          cfg.reload.records_per_page.should eq(10)
        end

      end

      it "should update instance_name variable" do
        sign_in admin
        cfg.instance_name.should_not eql('AX instance')
        put :update, {:id => cfg.to_param, :cfg => {instance_name: 'AX instance'}}
        cfg.reload.instance_name.should eql('AX instance')
      end

      it "should update records_per_page variable" do
        sign_in admin
        cfg.records_per_page.should_not eql(23)
        put :update, {:id => cfg.to_param, :cfg => {records_per_page: 23}}
        cfg.reload.records_per_page.should eql(23)
      end

      it "should update file_size variable" do
        sign_in admin
        cfg.file_size.should_not eql(17)
        put :update, {:id => cfg.to_param, :cfg => {file_size: 17}}
        cfg.reload.file_size.should eql(17.0)
      end

      it "should update hello_subtitle variable" do
        sign_in admin
        cfg.hello_subtitle.should_not eql('Hello world!')
        put :update, {:id => cfg.to_param, :cfg => {hello_subtitle: 'Hello world!'}}
        cfg.reload.hello_subtitle.should eql('Hello world!')
      end

      it "should update hello_message variable" do
        sign_in admin
        cfg.hello_message.should_not eql('Hello message')
        put :update, {:id => cfg.to_param, :cfg => {hello_message: 'Hello message'}}
        cfg.reload.hello_message.should eql('Hello message')
      end

      it "should update max_name_length variable" do
        sign_in admin
        cfg.max_name_length.should_not eql(13)
        put :update, {:id => cfg.to_param, :cfg => {max_name_length: 13}}
        cfg.reload.max_name_length.should eql(13)
      end

      it "should user_creates_account variable" do
        sign_in admin
        cfg.user_creates_account.should be false
        put :update, {:id => cfg.to_param, :cfg => {user_creates_account: true}}
        cfg.reload.user_creates_account.should be true
      end
    end

    describe "with invalid params" do
      it "assigns the cfg as @cfg" do
        sign_in admin
        Tmt::Cfg.any_instance.stub(:save).and_return(false)
        put :update, {:id => cfg.to_param, :cfg => { "instance_name" => "invalid value" }}
        assigns(:cfg).should eq(cfg)
      end

      it "re-renders the 'index' template" do
        sign_in admin
        Tmt::Cfg.any_instance.stub(:save).and_return(false)
        put :update, {:id => cfg.to_param, :cfg => { "instance_name" => "invalid value" }}
        response.should render_template("index")
      end
    end
  end

end
