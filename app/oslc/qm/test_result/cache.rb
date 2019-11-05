module Oslc
  module Qm
    module TestResult
      class Cache

        attr_reader :test_cases, :versions, :objects
        attr_accessor :project

        def initialize(objects=[], params={})
          @params = params
          @project = @params[:project]
          @objects = objects
          @versions = get_versions
          @test_cases = get_test_cases(@versions)
        end

        def version_for(object)
          if @objects.include?(object)
            version_id = object.version_id
            @versions[version_id]
          else
            raise "Test Result wasn't defined in Cache"
          end
        end

        def test_case_for(object)
          version_id = version_for(object).id
          test_case_id = @versions[version_id].test_case_id
          @test_cases[test_case_id]
        end

        private

        def get_test_cases(versions)
          result = {}
          test_case_ids = []
          versions.each do |key, version|
            test_case_ids << version.test_case_id
          end
          Tmt::TestCase.where(id: test_case_ids.uniq).each do |entry|
            result[entry.id] = entry
          end
          result
        end

        def get_versions
          result = {}
          version_ids = @objects.map(&:version_id).uniq
          Tmt::TestCaseVersion.where(id: version_ids).each do |entry|
            result[entry.id] = entry
          end
          result
        end

      end
    end
  end
end
