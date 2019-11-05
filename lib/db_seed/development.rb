require_relative 'base'

module Tmt
  module Lib
    class DBSeed
      class Development < ::Tmt::Lib::DBSeed::Base

        def person_bench
          password = "top-secret"
          users = User.where(email: 'michal@example.com')
          if users.size > 0
            user = users.first
          else
            user = User.create(name: 'michal', email: 'michal@example.com', password: password, password_confirmation: password, is_machine: false)
          end
          puts 'user: ' << user.name
          user.confirm!
          user.add_role :user
        end

        def enumerations
          st = ::Tmt::Enumeration.where(test_case_custom_field_id: nil, name: 'Statuses').first_or_create
          [
            [:new, 0],
            [:done, 1],
            [:accepted,2]
          ].each do |txt,val|
            ::Tmt::EnumerationValue.where(enumeration_id: st.id, numerical_value: val, text_value: txt).first_or_create
          end

          prios = ::Tmt::Enumeration.where(test_case_custom_field_id: nil, name: 'Priorities').first_or_create

          [
            [:minor, 0],
            [:enhancement, 1],
            [:medium, 2],
            [:significant, 3],
            [:high, 4]
          ].each do |txt,val|
            ::Tmt::EnumerationValue.where(enumeration_id: prios.id, numerical_value: val, text_value: txt).first_or_create
          end
        end

        def custom_fields
          [
            [:category,     :string, nil],
            [:spent_time,   :date,   nil],
            [:done_percent, :int,    0],
            [:status,       :int,    1]
          ].each do |name, type_name, default_value|
            element = Tmt::TestCaseCustomField.where(
              type_name: type_name,
              default_value: default_value,
              name: name
            ).first_or_create
          end

          Tmt::TestCaseCustomField.where(
            type_name: 'enum',
            default_value: nil,
            name: :priority
          ).first_or_create(
            enumeration_id: ::Tmt::Enumeration.last.id
          )
        end

        def test_cases
          Tmt::TestCase.create!(name: "tc1", description: "sample description", project: project, creator: person_admin, type_id: Tmt::TestCaseType.first.id)
          Tmt::TestCase.create!(name: "tc2", description: "other sample description", project: project, creator: person_admin, type_id: Tmt::TestCaseType.last.id)
          20.times do
            Tmt::TestCase.create!(name: rand(36**4).to_s(36), description: "yet another sample description", project: project, creator: person_admin, type_id: Tmt::TestCaseType.first.id)
          end
        end

      end
    end
  end
end
