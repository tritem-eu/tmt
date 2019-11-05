require_relative '../../lib/db_seed/test'

Tmt::Lib::DBSeed::Test.invoke(:test_case_types,
  :configuration,
  :custom_fields
)
Tmt::Cfg.first.update(time_zone: nil)
