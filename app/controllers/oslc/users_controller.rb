# encoding: utf-8

class Oslc::UsersController < Oslc::BaseController

  def show
    @user = ::User.find(params[:id])
    resource = Oslc::User::Resource.new(@user)
    respond_rdf { render text: resource.to_rdf, status: 200 }
    respond_xml { render text: resource.to_xml, status: 200 }
  end
end
