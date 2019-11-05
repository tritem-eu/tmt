class Oslc::Qm::TestCasesController < Oslc::BaseController

  # /oslc/qm/service-providers/1/test-cases/1.xml
  def show
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    @test_case = ::Tmt::TestCase.find(params[:id])
    authorize! :lead, @test_case

    add_etag(@test_case)

    unless params[:search].blank?
      @test_cases = Tmt::TestCase.search_records(params)
    else
      @test_cases = @service_provider.test_cases.page(params[:page]).per(Tmt::Cfg.first.records_per_page)
    end
    resource = ::Oslc::Qm::TestCase::Resource.new @test_case, {
      oslc_properties: params['oslc.properties']
    }
    respond_rdf { render text: resource.to_rdf, status: 200 }
    respond_xml { render text: resource.to_xml, status: 200 }
  end

  def query
    @provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @provider
    resources = ::Oslc::Qm::TestCase::Resources.new({
      provider: @provider,
      oslc_where: params["oslc.where"],
      oslc_select: params["oslc.select"],
      controller: self
    })

    respond_rdf { render text: resources.to_rdf, status: 200 }
    respond_xml { render text: resources.to_xml, status: 200 }
  end

  def create
    @project = Tmt::Project.find(params[:service_provider_id])
    creation_factory = Oslc::Qm::TestCase::CreationFactory.new(request.body.read, @project, current_user)
    authorize! :lead, creation_factory.test_case

    if creation_factory.save
      xml = creation_factory.response
      #format.html {redirect_to oslc_qm_service_provider_test_case_url(@project, @test_case), status: 201}
      respond_rdf {render text: xml, status: 201}
      respond_xml {render text: xml, status: 201}
    else
      xml = creation_factory.response
      respond_rdf {render text: xml, status: 400}
      respond_xml {render text: xml, status: 400}
    end
  end

  def update
    #https://jazz.net/library/article/1001
    @test_case = Tmt::TestCase.find(params[:id])
    @project = @test_case.project
    authorize! :lead, @test_case
    authorize! :no_lock, @test_case
    modify = Oslc::Qm::TestCase::Modify.new(request.body.read,
      project: @project,
      current_user: current_user,
      if_match: request.headers['If_Match'],
      test_case: @test_case,
      controller: self
    )

    modify.update
    respond_rdf {render text: modify.response, status: modify.status}
    respond_xml {render text: modify.response, status: modify.status}
  end

  def destroy
    @test_case = Tmt::TestCase.where(id: params[:id]).first
    when_exist(@test_case) do
      @project = @test_case.project
      authorize! :member, @project
      authorize! :no_lock, @test_case

      if @test_case.deleted_at.nil? and @test_case.set_deleted
        respond_xml {head 204}
        respond_rdf {head 204}
      else
        xml = Oslc::Error.new(400, "Bad Request").to_rdfxml
        respond_xml {render text: xml, status: 400}
        respond_rdf {render text: xml, status: 400}
      end
    end
  end

  def selection_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider

    if params[:search].present?
      @test_cases = Tmt::TestCase.search_records(params).results
    else
      @test_cases = @service_provider.test_cases.page(params[:page]).per(Tmt::Cfg.first.records_per_page)
    end

    @response = selection_dialog_response(@test_cases, :name, :oslc_qm_service_provider_test_case_url, [@service_provider, nil])

    render layout: 'oslc_ui'
  end

  def new_creation_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider

    @test_case = Tmt::TestCase.new
    @test_case.creator = current_user
    @test_case.project = @service_provider
    @custom_fields = Tmt::TestCaseCustomField.all

    render layout: 'oslc_ui'
  end

  def creation_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider

    @test_case = Tmt::TestCase.new(test_case_params)
    @test_case.creator = current_user
    @test_case.project = @service_provider
    @test_case.type_id = Tmt::OslcCfg.cfg.test_case_type_id

    respond_to do |format|
      if @test_case.save
        @response = selection_dialog_response([@test_case], :name, :project_test_case_url, [@service_provider, nil])
        format.js { render layout: false }
        format.html { redirect_to new_creation_dialog_oslc_qm_service_provider_test_cases_url(@service_provider) }
      else
        @custom_fields = Tmt::TestCaseCustomField.all
        format.js { render layout: false }
        format.html { render layout: 'oslc_ui', action: 'new_creation_dialog' }
      end
    end
  end

  private

  def test_case_params
    params.require(:test_case).permit(:name, :description, :type_id, :custom_field_values => [:value])
  end

end
