module Oslc
  module Core
    # properties are defined on link:
    #   http://open-services.net/wiki/automation/OSLC-Automation-Specification-Version-2.0/#State-and-Verdict-properties
    class Properties
      class Base

        def self.state_url(name)
          if ['new', 'queued', 'inProgress', 'canceling', 'canceled', 'complete'].include?(name)
            "http://open-services.net/ns/auto##{name}"
          end
        end

        def self.state_urls
          result = []
          ['new', 'queued', 'inProgress', 'canceling', 'canceled', 'complete'].each do |name|
            result << state_url(name)
          end
          result
        end

        def self.verdict_url(name)
          if ['unavailable', 'passed', 'warning', 'failed', 'error'].include?(name)
            "http://open-services.net/ns/auto##{name}"
          end
        end

        def self.verdict_urls
          result = []
          ['unavailable', 'passed', 'warning', 'failed', 'error'].each do |name|
            result << verdict_url(name)
          end
          result
        end
      end
    end
  end
end
