class Oslc::Qm::TestScriptsController < Oslc::BaseController

  def show
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider

    @version = ::Tmt::TestCaseVersion.find(params[:id])
    resource = ::Oslc::Qm::TestScript::Resource.new(@version, {
      oslc_properties: params['oslc.properties']
    })
    respond_rdf { render text: resource.to_rdf }
    respond_xml { render text: resource.to_xml }
  end

  def query
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider
    resources = Oslc::Qm::TestScript::Resources.new({
      provider: @service_provider,
      controller: self,
      oslc_where: params['oslc.where'],
      oslc_select: params['oslc.select']
    })

    respond_rdf {render text: resources.to_rdf, status: 200}
    respond_xml {render text: resources.to_xml, status: 200}
  end

  # GET /oslc/qm/service-providers/1/test-scripts/1/download.rdf
  def download
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider

    @version = ::Tmt::TestCaseVersion.find(params[:id])
    send_data @version.content, filename: "#{@version.file_name}"
  end


  def selection_dialog
    @service_provider = ::Tmt::Project.find(params[:service_provider_id])
    authorize! :member, @service_provider

    @test_scripts = @service_provider.test_case_versions
    if params[:search].present?
      @test_scripts = @test_scripts.where(comment: params[:search])
    end

    @response = selection_dialog_response(@test_scripts, :content, :oslc_qm_service_provider_test_script_url, [@service_provider, 'nil.test_case', nil])

    render layout: 'oslc_ui'
  end

end
