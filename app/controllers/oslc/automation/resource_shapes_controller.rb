module Oslc
  module Automation
    class ResourceShapesController < Oslc::BaseController

      def show
        automation_resource = nil
        case params[:id]
        when "adapter" then
          automation_resource = ::Oslc::Automation::Adapter::ResourceShape.new()
        when "request" then
          automation_resource = ::Oslc::Automation::Request::ResourceShape.new()
        when "result" then
          automation_resource = ::Oslc::Automation::Result::ResourceShape.new()
        when "plan" then
          automation_resource = ::Oslc::Automation::Plan::ResourceShape.new()
        else
          nil
        end

        if automation_resource
          respond_rdf { render text: automation_resource.to_rdf, status: 200 }
          respond_xml { render text: automation_resource.to_xml, status: 200 }
        else
          error = Oslc::Error.new(400, "'#{params[:id]}'identifier is incorrect." )
          respond_rdf { render text: error.to_rdf, status: 400 }
          respond_xml { render text: error.to_xml, status: 400 }
        end

      end
    end
  end
end
