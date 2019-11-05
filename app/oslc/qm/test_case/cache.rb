module Oslc
  module Qm
    module TestCase
      class Cache

        attr_reader :versions, :objects
        attr_accessor :project

        def initialize(objects=[], params={})
          @params = params
          @project = @params[:project]
          @objects = objects
          @versions = get_versions
        end

        def version_for(object)
          result = nil
          if @objects.include?(object)
            @versions.each do |version_id, version|
              if version.test_case_id == object.id
                if result.nil? or result.created_at < version.created_at
                  result = version
                end
              end
            end
            result
          else
            raise "Test Result wasn't defined in Cache"
          end
        end

        private

        def get_versions
          result = {}
          test_case_ids = @objects.map(&:id).uniq
          Tmt::TestCaseVersion.where(test_case_id: test_case_ids).each do |entry|
            result[entry.id] = entry
          end
          result
        end

      end
    end
  end
end
