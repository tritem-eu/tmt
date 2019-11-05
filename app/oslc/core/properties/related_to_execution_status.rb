module Oslc
  module Core
    class Properties
      class RelatedToExecutionStatus

        Entry = Struct.new(:execution_status, :oslc_state, :oslc_verdict, :is_master)

        def self.list
          [
            add_master_entry('error',      'complete',   'error'),
            add_master_entry('failed',     'complete',   'failed'),
            add_master_entry('passed',     'complete',   'passed'),
            add_custom_entry('executing',  'queued',     nil),
            add_custom_entry('error',      'canceled',   nil),
            add_custom_entry('error',      'canceling',  nil),
            add_master_entry('executing',  'inProgress', nil),
            add_custom_entry('executing',  'queued',     nil),
            add_master_entry('none',       'new',        nil)
          ]
        end

      private

        def self.add_custom_entry(execution_status, state, verdict)
          verdict = build_property_url(verdict)
          state = build_property_url(state)
          Entry.new(execution_status, state, verdict, false)
        end

        def self.add_master_entry(execution_status, state, verdict)
          verdict = build_property_url(verdict)
          state = build_property_url(state)
          Entry.new(execution_status, state, verdict, true)
        end

        # For example:
        #   self.build_property_url('error') #=> "http://open-services.net/ns/auto#error"
        def self.build_property_url(name)
          result = nil
          if not name == nil
            result = "http://open-services.net/ns/auto##{name}"
          end
          result
        end

      end
    end
  end
end
