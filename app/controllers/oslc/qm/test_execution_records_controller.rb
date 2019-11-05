class Oslc::Qm::TestExecutionRecordsController < Oslc::BaseController

  def show
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    @execution = ::Tmt::Execution.find(params[:id])
    resource = ::Oslc::Qm::TestExecutionRecord::Resource.new(@execution, {
      project: @project,
      oslc_properties: params["oslc.properties"]
    })
    respond_rdf { render text: resource.to_rdf, status: 200 }
    respond_xml { render text: resource.to_xml, status: 200 }
  end

  def query
    @project = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @project
    resources = ::Oslc::Qm::TestExecutionRecord::Resources.new({
      provider: @project,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"],
    })
    respond_rdf { render text: resources.to_rdf, status: 200 }
    respond_xml { render text: resources.to_xml, status: 200 }
  end

  def selection_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])

    @test_execution_records = @service_provider.executions
    if params[:search].present?
      test_case_version = ::Tmt::TestCaseVersion.arel_table
      @test_execution_records = @test_execution_records.joins(:version).where(test_case_version[:comment].eq(params[:search]))
    end

    @response = selection_dialog_response(@test_execution_records, :title, :project_campaign_execution_url, [@service_provider, 'nil.campaign', nil])
    render layout: 'oslc_ui'
  end

end
