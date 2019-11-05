module Oslc
  module Automation
    module Plan
      class Cache

        attr_reader :project

        def initialize(objects=[], params={})
          @project = objects.first.project if objects.any?
          @objects = objects
          @test_cases = get_test_cases
          @versions = get_versions
          @test_runs = get_test_runs
        end

        def test_run_for(object)
          @test_runs[object.test_run_id]
        end

        def test_case_version_for(object)
          @versions[object.version_id]
        end

        def test_case_for(object)
          version = test_case_version_for(object)
          @test_cases[version.test_case_id]
        end

        private

        def entries_to_hash(entries)
          result = {}
          entries.each do |entry|
            result[entry.id] = entry
          end
          result
        end

        def get_test_runs
          entries = Tmt::TestRun.where(id: @objects.map(&:test_run_id).uniq)
          entries_to_hash(entries)
        end

        def get_test_cases
          test_case_ids = get_versions.values.map(&:test_case_id).uniq
          entries = Tmt::TestCase.where(id: test_case_ids)
          entries_to_hash(entries)
        end

        def get_versions
          entries = Tmt::TestCaseVersion.where(id: @objects.map(&:version_id).uniq)
          entries_to_hash(entries)
        end

      end
    end
  end
end
