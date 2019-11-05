# encoding: utf-8

class Oslc::Automation::ResultsController < Oslc::BaseController

  def create
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    automation_result = Oslc::Automation::Result::CreationFactory.new(request.body.read, project: @project)
    @execution = ::Tmt::Execution.find(automation_result.automation_request_id)
    authorize! :planned_or_executing, @execution.test_run
    if automation_result.save
      content = automation_result.response
      respond_rdf { render text: content, status: 201 }
      respond_xml { render text: content, status: 201 }
    else
      content = automation_result.response
      respond_rdf { render text: content, status: 400 }
      respond_xml { render text: content, status: 400 }
    end
  end

  def show
    @project = ::Tmt::Project.find(params[:service_provider_id])
    @execution = ::Tmt::Execution.find(params[:id])
    authorize! :read_for_oslc, @execution
    automation_result = Oslc::Automation::Result::Resource.new(@execution, {
      oslc_properties: params['oslc.properties']
    })
    respond_rdf { render text: automation_result.to_rdf, status: 200 }
    respond_xml { render text: automation_result.to_xml, status: 200 }
  end

  def query
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    params["oslc.select"] = "*" if params["oslc.select"].blank?
    resources = ::Oslc::Automation::Result::Resources.new({
      provider: @project,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"],
      controller: self
    })

    respond_rdf { render text: resources.to_rdf, status: 200 }
    respond_xml { render text: resources.to_xml, status: 200 }
  end

end
