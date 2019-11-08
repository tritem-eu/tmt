require 'spec_helper'

describe Oslc::Core::Query, type: :lib do
  class OslcCoreQuery < ::Oslc::Core::Query
    define_property "dcterms:modified" do
      {
        parser: :date,
        model_attribute: :updated_at
      }
    end

    define_property "dcterms:identifier" do
      {
        parser: :parse_identifier,
        url_pattern: @@routes.oslc_automation_service_provider_result_url('*', '*'),
        model_attribute: :id
      }
    end

    def after_initialize
      @class_name = ::Tmt::Execution
      @where = @class_name.where(id: @options[:execution_ids])
    end

  end

  let(:execution) { create(:execution) }
  let(:foreign_execution) { create(:execution) }

  let(:object) { OslcCoreQuery.new(execution_ids: [execution.id, foreign_execution.id]) }

  it 'should return get_id_from_url' do
    pattern = 'http://example.com/oslc/service-provider/*/results/*'
    url = 'http://example.com/oslc/service-provider/19/results/23'
    object.get_ids_from_url(url, pattern).should eq(['19', '23'])
  end

  it 'should return collection executions which equals to pattern of identifier' do
    url = "http://example.com/oslc/service-provider/19/results/#{execution.id}"
    result = object.where("dcterms:identifier=\"#{url}\"")
    result.should eq([execution])
  end

  it 'should return all executions' do
    url = "http://example.com/oslc/service-provider/19/results/#{execution.id}"
    result = object.where()
    result.should eq([execution, foreign_execution])
  end

end
