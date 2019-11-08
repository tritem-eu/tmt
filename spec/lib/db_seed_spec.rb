require 'spec_helper'

require Rails.root.join('lib/db_seed/production')
require Rails.root.join('lib/db_seed/test')
require Rails.root.join('lib/db_seed/development')

describe ::Tmt::Tasks::Seed, type: :lib do
  describe "Uploading default Custom Fields variables for Sandbox" do

    it "should initialize seed for test environment" do
      expect do
        Tmt::Lib::DBSeed::Test.invoke(:test_case_types,
          :configuration,
          :custom_fields
        )
      end.to_not raise_error
    end

    it "should initialize seed for development environment" do
      expect do
        Tmt::Lib::DBSeed::Development.invoke(:roles,
          :person_admin,
          :person_bench,
          :test_case_types,
          :configuration,
          :enumerations,
          :custom_fields,
          :project,
          :test_cases,
          :test_case_version,
          :campaign,
          :test_run
        )
      end.to_not raise_error
    end

    it "should initialize seed for production environment" do
      expect do
        Tmt::Lib::DBSeed::Production.invoke(:roles,
          :person_admin,
          :test_case_types,
          :configuration,
          :custom_fields,
          :project,
          :test_case, # For the test of Lyo
          :test_case_version,
          :campaign,
          :test_run
        )
      end.to_not raise_error
    end

  end
end
