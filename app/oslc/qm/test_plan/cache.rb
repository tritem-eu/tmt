module Oslc
  module Qm
    module TestPlan
      class Cache

        attr_reader :executions, :test_cases
        attr_accessor :project

        def initialize(objects=[], params={})
          @params = params
          @project = @params[:project]
          @objects = objects
          @test_cases = get_test_cases
          @executions = get_executions
          @versions = get_versions
        end

        def test_cases_for(object)
          unless @objects.include?(object)
            raise "Test Plan Resource wasn't defined in Cache"
          end
          version_ids = []
          @executions.each do |execution_id, execution|
            if execution.test_run_id == object.id
              version_ids << execution.version_id
            end
          end
          versions = select_from(@versions, version_ids)
          test_case_ids = versions.map(&:test_case_id)
          select_from(@test_cases, test_case_ids)
        end

        def select_from(objects, ids)
          result = []
          ids = ids.uniq
          ids.each do |id|
            result << objects[id]
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

        def get_executions
          test_run_ids = @objects.map(&:id).uniq
          test_run = Tmt::TestRun.arel_table
          entries = Tmt::Execution.joins(:test_run).where(test_run[:id].in(test_run_ids))
          entries_to_hash(entries)
        end

        def get_versions
          test_run_ids = @objects.map(&:id).uniq
          test_run = Tmt::TestRun.arel_table
          entries = Tmt::TestCaseVersion.joins(:test_runs).where(test_run[:id].in(test_run_ids))
          entries_to_hash(entries)
        end

        def get_test_cases
          test_run_ids = @objects.map(&:id).uniq
          test_run = Tmt::TestRun.arel_table
          entries = Tmt::TestCase.joins(:test_runs).where(test_run[:id].in(test_run_ids))
          entries_to_hash(entries)
        end

      end
    end
  end
end
