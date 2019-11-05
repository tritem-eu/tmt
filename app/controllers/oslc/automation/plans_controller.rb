# encoding: utf-8

class Oslc::Automation::PlansController < Oslc::BaseController

  def show
    @project = ::Tmt::Project.find(params[:service_provider_id])
    @automation_plan = ::Tmt::Execution.find(params[:id])
    authorize! :member, @project
    automation_plan = Oslc::Automation::Plan::Resource.new(@automation_plan, {
      oslc_properties: params['oslc.properties']
    })
    respond_rdf { render text: automation_plan.to_rdf, status: 200 }
    respond_xml { render text: automation_plan.to_xml, status: 200}
  end

  def query
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    resources = ::Oslc::Automation::Plan::Resources.new({
      provider: @project,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"]
    })
    respond_rdf { render text: resources.to_rdf, status: 200 }
    respond_xml { render text: resources.to_xml, status: 200 }
  end
end
