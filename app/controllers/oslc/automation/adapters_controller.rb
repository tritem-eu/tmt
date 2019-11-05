# encoding: utf-8

class Oslc::Automation::AdaptersController < Oslc::BaseController

  def show
    @project = ::Tmt::Project.find(params[:service_provider_id])
    @automation_adapter = ::Tmt::AutomationAdapter.find(params[:id])
    authorize! :member, @project
    adapter = Oslc::Automation::Adapter::Resource.new(@automation_adapter, {
      oslc_properties: params['oslc.properties']
    })
    respond_rdf { render text: adapter.to_rdf, status: 200 }
    respond_xml { render text: adapter.to_xml, status: 200 }
  end

  def create
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    automation_adapter = Oslc::Automation::Adapter::CreationFactory.new(request.body.read, project: @project, machine_id: current_user.id)
    if automation_adapter.save
      content = automation_adapter.response
      respond_rdf { render text: content, status: 201 }
      respond_xml { render text: content, status: 201 }
    else
      content = automation_adapter.response
      respond_rdf { render text: content, status: 400 }
      respond_xml { render text: content, status: 400 }
    end
  end

  def query
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    resources = ::Oslc::Automation::Adapter::Resources.new({
      provider: @project,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"]
    })

    respond_rdf { render text: resources.to_rdf }
    respond_xml { render text: resources.to_xml }
  end
end
