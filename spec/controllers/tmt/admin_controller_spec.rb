require 'spec_helper'

describe Tmt::AdminController do
  extend ::CanCanHelper

  let(:admin) { create(:admin) }

  before do
    ready(Tmt::Cfg.first)
  end

  describe "GET show" do

    it_should_not_authorize(self, [:no_logged, :foreign]) do
      get :show
    end

    it "should render 'show' template" do
      sign_in admin

      get :show
      request.should render_template('show')
    end
  end
end
