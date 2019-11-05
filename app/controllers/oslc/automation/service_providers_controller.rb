# encoding: utf-8

class Oslc::Automation::ServiceProvidersController < Oslc::BaseController

  def index
    @projects = current_user.projects
    content = Oslc::Automation::ServiceProviderCatalog.new(@projects).to_rdfxml
    respond_rdf { render text: content, status: 200 }
    respond_xml { render text: content, status: 200 }
  end

  def show
    @project = ::Tmt::Project.find(params[:id])
    authorize! :member, @project
    content = Oslc::Automation::ServiceProvider.new(@project).to_xml

    respond_rdf {render text: content }
    respond_xml {render text: content }
  end

end
