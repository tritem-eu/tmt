class Oslc::Qm::TestPlansController < Oslc::BaseController

  # /oslc/qm/service-providers/1/test-plans/1.xml
  def show
    @test_run = ::Tmt::TestRun.find(params[:id])
    @project = @test_run.project

    authorize! :member, @project
    resource = ::Oslc::Qm::TestPlan::Resource.new(@test_run, {
      oslc_properties: params['oslc.properties']
    })
    respond_rdf { render text: resource.to_rdf, status: 200 }
    respond_xml { render text: resource.to_xml, status: 200 }
  end

  def query
    @provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @provider
    resources = ::Oslc::Qm::TestPlan::Resources.new({
      provider: @provider,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"]
    })

    respond_rdf { render text: resources.to_rdf }
    respond_xml { render text: resources.to_xml }
  end

  def selection_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    if params[:search].present?
      @test_plans = Tmt::TestRun.search_records(params, @service_provider)
    else
      @test_plans = @service_provider.test_runs.page(params[:page]).per(Tmt::Cfg.first.records_per_page)
    end

    @response = selection_dialog_response(@test_plans, :name, :oslc_qm_service_provider_test_plan_url, [@service_provider, nil])

    render layout: 'oslc_ui'
  end

  def new_creation_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :lead, @service_provider
    @campaign = @service_provider.open_campaign

    @test_plan = Tmt::TestRun.new
    @test_plan.campaign = @campaign
    @executors = @service_provider.users
    @custom_fields = Tmt::TestRunCustomField.all

    render layout: 'oslc_ui'
  end

  def creation_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :lead, @service_provider
    @campaign = @service_provider.open_campaign

    @test_plan = Tmt::TestRun.new(test_plan_params)
    @test_plan.creator = current_user
    @executors = @service_provider.users

    @test_plan.campaign = @campaign
    @custom_fields = Tmt::TestRunCustomField.all
    respond_to do |format|
      if @test_plan.save
        @response = selection_dialog_response([@test_plan], :name, :project_campaign_test_run_url, [@service_provider, @campaign, nil])
        format.js { render layout: false }
        format.html { redirect_to new_creation_dialog_oslc_qm_service_provider_test_runs_url(@service_provider) }
      else
        format.js { render layout: false }
        format.html { render layout: 'oslc_ui', action: 'new_creation_dialog' }
      end
    end
  end

  # Executor can select status execution
  # GET /oslc/qm/service-providers/1/test-plans/1/set-status-execution
  def set_status_executing
    @test_run = Tmt::TestRun.find(params[:id])
    authorize! :executor, @test_run
    @test_run.set_status_executing

    respond_to do |format|
      format.json { render json: {status: @test_run.reload.status} }
    end
  end


  # GET /oslc/qm/service-providers/1/test-plans/unexecuted
  def unexecuted
    result = {}

    ::Tmt::TestRun.where(executor: current_user, status: 3).each do |test_run|
      result[test_run.id.to_s] = test_run.executions.select do |execution|
        execution.status.to_sym == :none
      end.map{ |execution| execution.version_id.to_s}
    end
    respond_to do |format|
      format.json {render json: result}
    end
  end

  private

  def test_plan_params
    params.require(:test_run).permit(:name, :description, :due_date, :executor_id, :campaign_id, :custom_field_values => [:value])
  end

end
