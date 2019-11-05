class Oslc::Qm::ServiceProvidersController < Oslc::BaseController

  def index
    @projects = current_user.projects
    xml = Oslc::Qm::ServiceProviderCatalog.new(@projects).to_rdfxml

    respond_rdf { render text: xml, status: 200 }
    respond_xml { render text: xml, status: 200 }
    respond_atom { render text: xml, status: 200 }
  end

  def show
    @project = ::Tmt::Project.find(params[:id])
    authorize! :member, @project
    service_provider = Oslc::Qm::ServiceProvider.new(@project)
    respond_rdf {render text: service_provider.to_xml, status: 200 }
    respond_xml {render text: service_provider.to_xml, status: 200 }
    respond_atom {render text: service_provider.to_atom, status: 200 }
  end

end
