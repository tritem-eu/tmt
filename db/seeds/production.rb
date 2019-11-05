require_relative '../../lib/db_seed/production'

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
