module Oslc
  module Core
    class Properties
      class StateAndVerdict
        def initialize(state, verdict)
          @verdict = verdict
          @state = state
          @relations = RelatedToExecutionStatus.list
        end

        def map_to_execution_status
          @relations.each do |relation|
            if not @state == relation.oslc_state
              next
            end
            if not @verdict == relation.oslc_verdict
              next
            end
            return relation.execution_status
          end
          nil
        end
      end
    end
  end
end
