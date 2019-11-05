require_relative 'base'

module Tmt
  module Lib
    class DBSeed
      class Production < ::Tmt::Lib::DBSeed::Base
        def custom_fields
          [
            [:category, :string, nil],
            [:spent_time, :date, nil],
            [:done_percent, :int, 0],
            [:status, :int, 1],
          ].each do |name, type_name, default_value|
            Tmt::TestCaseCustomField.where(
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
