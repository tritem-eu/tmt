module Oslc
  module Core
    class Properties
      class Verdict

        def initialize(verdict)
          @verdict = verdict.gsub(/^<|>$/, '')
        end

        def to_execution_statuses
          result = []
          RelatedToExecutionStatus.list.map do |item|
            if item.oslc_verdict == @verdict
              result << item.execution_status
            end
          end
          result.uniq
        end

      end
    end
  end
end
