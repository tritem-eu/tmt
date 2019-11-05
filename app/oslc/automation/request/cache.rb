module Oslc
  module Automation
    module Request
      class Cache

        attr_reader :project

        def initialize(objects=[], params={})
          @project = objects.first.project if objects.any?
          @grouped_automation_adapter = get_grouped_automation_adapter
          @requests = objects
          @test_runs = get_test_runs
          @versions = get_versions
          @test_cases = get_test_cases(@versions)
          @custom_fields = get_custom_fields(@test_cases)
        end

        def adapters_for(user_id)
          adapters = @grouped_automation_adapters[user_id]
          if not adapters
            []
          else
            adapters
          end

        end

        def version_for(request)
          if @requests.include?(request)
            version_id = request.version_id
            @versions[version_id]
          else
            raise "Automation Request wasn't defined in Cache"
          end
        end

        def test_run_for(request)
          if @requests.include?(request)
            test_run_id = request.test_run_id
            @test_runs[test_run_id]
          else
            raise "Automation Request wasn't defined in Cache"
          end
        end

        def test_case_for(request)
          if @requests.include?(request)
            version_id = request.version_id
            test_case_id = @versions[version_id].test_case_id
            @test_cases[test_case_id]
          else
            raise "Automation Request wasn't defined in Cache"
          end
        end

        def custom_field_values_for(automation_request)
          test_case = test_case_for(automation_request)
          result = []
          @custom_fields.each do |id, custom_field_value|
            result << custom_field_value if custom_field_value.test_case_id == test_case.id
          end
          result
        end

        private

        def entries_to_hash(entries)
          result = {}
          entries.each do |entry|
            result[entry.id] = entry
          end
          result
        end

        def get_grouped_automation_adapter
          project_id = nil
          project_id = @project.id if @project
          @grouped_automation_adapters = Tmt::AutomationAdapter.where(
            project_id: project_id
          ).group_by(&:user_id)
        end

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

        def get_custom_fields(test_cases)
          test_case_ids = test_cases.keys
          entries = Tmt::TestCaseCustomFieldValue.where(test_case_id: test_case_ids).uniq
          entries_to_hash(entries)
        end

        def get_test_runs
          test_run_ids = @requests.map(&:test_run_id).uniq
          entries = Tmt::TestRun.where(id: test_run_ids)
          entries_to_hash(entries)
        end

        def get_versions
          result = {}
          version_ids = @requests.map(&:version_id).uniq
          Tmt::TestCaseVersion.where(id: version_ids).each do |entry|
            result[entry.id] = entry
          end
          result
        end

      end
    end
  end
end
