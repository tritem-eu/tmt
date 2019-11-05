require_relative '../../lib/db_seed/development'

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
