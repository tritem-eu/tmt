require_relative 'base'

module Test

end

module Tmt
  module Lib
    class DBSeed
      class Test < ::Tmt::Lib::DBSeed::Base
        def configuration
          ::Tmt::Cfg.where(instance_name: "TMT").first_or_create
        end

        def custom_fields
          [
            [:comment, :string, nil],
            [:category, :string, nil],
            [:spent_time, :date, nil],
            [:done_percent, :int, 0],
            [:status, :int, 1],
          ].each do |name, type_name, default_value|
            ::Tmt::TestCaseCustomField.where(
              type_name: type_name,
              default_value: default_value,
              name: name
            ).first_or_create
          end
        end
      end
    end
  end
end
