module ActionDispatch
  module Routing
    module PolymorphicRoutes
      alias_method :original_build_named_route_call, :build_named_route_call

      def build_named_route_call(records, inflection, options = {})
        original_build_named_route_call(records, inflection, options).gsub("tmt_", "").gsub("tmt_", "")
      end
    end
  end
end
