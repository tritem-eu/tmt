module Oslc
  module Core
    class Properties
      class TakenAndExecutionStatus

        def status_map_to_taken(status, taken)
          if status.to_s == 'none'
            return false
          end
          return true
        end

      end
    end
  end
end
