module Oslc
  module Core
    class Properties
      class ExecutionStatus
        def initialize(status)
          @status = status.to_s
          @relations = RelatedToExecutionStatus.list
        end

        def map_to_state_property
          @relations.each do |relation|
           if relation.is_master == true
              if @status == relation.execution_status
                return relation.oslc_state
              end
            end
          end
          nil
        end

        def map_to_verdict_property
          @relations.each do |relation|
            if relation.is_master == true
              if @status == relation.execution_status
                return relation.oslc_verdict
              end
            end
          end
          nil
        end
      end
    end
  end
end
