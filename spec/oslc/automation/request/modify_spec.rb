require 'spec_helper'

describe Oslc::Automation::Request::Modify do
  include Support::Oslc

  let(:execution) do
    create(:execution, progress: 13, status: nil)
  end

  let(:project) do
    project = create(:project)
    project.add_member(create(:user))
    project
  end

  def build_rdf_content(selectors=[])
    Tmt::XML::RDFXML.new(xmlns: {
      rdf: :rdf,
      rqm_auto: :rqm_auto,
      oslc_auto: :oslc_auto
    }, xml: {lang: :en}) do |xml|
      if selectors.include?(:type)
        xml.add "rdf:type", rdf: {resource: 'http://open-services.net/ns/auto#AutomationRequest'}
      end
      if selectors.include?(:progress_23)
        xml.add("rqm_auto:progress") do
          23
        end
      end
      if selectors.include?(:taken)
      xml.add "rqm_auto:taken", rdf: {datatype: "http://www.w3.org/2001/XMLSchema#boolean"} do
        'true'
      end
      end
      if selectors.include?(:state_complete)
        xml.add "oslc_auto:state", rdf: {resource: 'http://open-services.net/ns/auto#complete'}
      end
    end.to_xml
  end

  def modify_for_elements(selectors=[])
    rdf_content = build_rdf_content(selectors)
    modify = Oslc::Automation::Request::Modify.new(rdf_content,
      project: project,
      object: execution,
      test_run: execution.test_run
    )
    modify.update
    execution.reload
    modify
  end

  describe "when RDF content is correct" do

    it 'modifies all properties' do
      execution.progress.should equal(13)
      execution.status.should equal(execution.class::STATUS_NONE)
      modify_for_elements([:type, :progress_23, :taken, :state_complete])
      execution.progress.should equal(23)
      execution.status.should eq(execution.class::STATUS_EXECUTING.to_s)
    end

    it 'modifies progress property' do
      execution.progress.should equal(13)
      execution.status.should equal(execution.class::STATUS_NONE)
      modify_for_elements([:type, :progress_23])
      execution.progress.should equal(23)
      execution.status.should eq(execution.class::STATUS_NONE.to_s)
    end

    it 'modifies taken property' do
      execution.status.should eq(execution.class::STATUS_NONE)
      modify = modify_for_elements([:type, :taken])
      execution.status.should eq(execution.class::STATUS_EXECUTING.to_s)
    end

    it "modifies progress property when 'state' is completed" do
      execution.update(comment: 'Passed Test Stand', status: 'passed')
      execution.progress.should eq(13)
      execution.status.should eq(execution.class::STATUS_PASSED.to_s)
      modify = modify_for_elements([:type, :progress_23, :state_complete])
      execution.progress.should eq(23)
      execution.status.should eq(execution.class::STATUS_PASSED.to_s)
    end
  end

  describe "when RDF content is incorrect" do
    it 'modifies' do
      execution.progress.should equal(13)
      execution.status.should equal(execution.class::STATUS_NONE)
      updated_at = execution.updated_at
      modify = modify_for_elements([:progress_23])
      modify.status.should eq(400)
      modify.response.should include("<oslc:message>Type of content is incorrect</oslc:message>")
      execution.reload.updated_at.to_s.should eq(updated_at.to_s)
    end
  end
end
