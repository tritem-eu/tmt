module Oslc
  module Qm
    class ResourceShapesController < Oslc::BaseController

      def show
        qm_shape = nil
        if params[:id] == "test-case"
          qm_shape = ::Oslc::Qm::TestCase::ResourceShape.new()
        elsif params[:id] == "test-plan"
          qm_shape = ::Oslc::Qm::TestPlan::ResourceShape.new()
        elsif params[:id] == "test-script"
          qm_shape = ::Oslc::Qm::TestScript::ResourceShape.new()
        elsif params[:id] == "test-execution-record"
          qm_shape = ::Oslc::Qm::TestExecutionRecord::ResourceShape.new()
        elsif params[:id] == "test-result"
          qm_shape = ::Oslc::Qm::TestResult::ResourceShape.new()
        end

        if qm_shape
          respond_rdf { render text: qm_shape.to_rdf, status: 200 }
          respond_xml { render text: qm_shape.to_xml, status: 200 }
        else
          error = Oslc::Error.new(400, "'#{params[:id]}'identifier is incorrect." )
          respond_rdf { render text: error.to_rdf, status: 400 }
          respond_xml { render text: error.to_xml, status: 400 }
        end

      end
    end
  end
end
