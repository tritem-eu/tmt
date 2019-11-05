module Oslc
  module Core
    class Properties
      class State

        def initialize(state)
          @state = state.gsub(/^<|>$/, '')
        end

        def to_execution_statuses
          result = []
          RelatedToExecutionStatus.list.map do |item|
            if item.oslc_state == @state
              result << item.execution_status
            end
          end
          result.uniq
        end

      end
    end
  end
end
