# encoding: utf-8

class Oslc::Automation::RequestsController < Oslc::BaseController

  def show
    @automation_request = ::Tmt::Execution.find(params[:id])
    @project = @automation_request.project
    authorize! :member, @project
    automation_request = Oslc::Automation::Request::Resource.new(@automation_request, {
      oslc_properties: params['oslc.properties'],
      project: @project
    })
    respond_rdf { render text: automation_request.to_rdf, status: 200 }
    respond_xml { render text: automation_request.to_xml, status: 200}
  end

  def update
    @execution = ::Tmt::Execution.find(params[:id])
    @test_run = @execution.test_run

    authorize! :editable_for_oslc, @execution
    @project = @execution.project
    modify = Oslc::Automation::Request::Modify.new(request.body.read,
      project: @project,
      if_match: request.headers['If_Match'],
      object: @execution,
      test_run: @test_run,
    )

    modify.update
    respond_rdf { render text: modify.response, status: modify.status }
    respond_xml { render text: modify.response, status: modify.status }
  end

  def query
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    params["oslc.select"] = "*" if params["oslc.select"].blank?
    resources = ::Oslc::Automation::Request::Resources.new({
      provider: @project,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"]
    })

    respond_rdf { render text: resources.to_rdf, status: 200 }
    respond_xml { render text: resources.to_xml, status: 200 }
  end
end
