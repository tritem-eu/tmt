class Oslc::Qm::TestResultsController < Oslc::BaseController

  def show
    @test_result = ::Tmt::Execution.find(params[:id])
    @test_plan = @test_result.test_run
    authorize! :executor, @test_plan
    test_result = ::Oslc::Qm::TestResult::Resource.new(@test_result, {
      oslc_properties: params['oslc.properties']
    })

    respond_rdf { render text: test_result.to_rdf, status: 200 }
    respond_xml { render text: test_result.to_xml, status: 200}
  end

  def query
    @provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @provider
    resources = ::Oslc::Qm::TestResult::Resources.new({
      provider: @provider,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"],
      controller: self
    })
    respond_rdf { render text: resources.to_rdf }
    respond_xml { render text: resources.to_xml }
  end

  def selection_dialog
    @provider = ::Tmt::Project.find(params[:service_provider_id])

    @test_results = @provider.executions
    if params[:search].present?
      test_case_version = ::Tmt::TestCaseVersion.arel_table
      @test_results = @test_results.joins(:version).where(test_case_version[:comment].eq(params[:search]))
    end

    @response = selection_dialog_response(@test_results, :title, :project_campaign_execution_url, [@provider, 'nil.campaign', nil])
    render layout: 'oslc_ui'
  end

  # Saving the results
  # PUT /oslc/qm/service-providers/1/test-results/1
  def update
    @test_result = Tmt::Execution.find(params[:id])
    @test_run = @test_result.test_run
    authorize! :planned_or_executing, @test_run
    @test_run.set_status_executing
    @test_result.update(
      datafiles: params[:datafiles],
      status: params[:status],
      result_path: params[:result_path]
    )
    xml = Tmt::XML::RDFXML.new(xmlns: {
      rdf: :rdf,
    }) do |xml|

    end.to_xml

    respond_to do |format|
      format.rdf { render text: xml}
      format.xml { render text: xml}
    end
  end

end
