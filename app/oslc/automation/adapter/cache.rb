module Oslc
  module Automation
    module Adapter
      class Cache

        attr_reader :project

        def initialize(objects=[], params={})
          @project = objects.first.project if objects.any?
          @objects = objects
          @users = get_users
          @machines = get_machines
        end

        def user_for(object)
          @users[object.user_id]
        end

        def machine_for(object)
          user = user_for(object)
          return nil unless user
          @machines.each do |id, machine|
            return machine if user.id == machine.user_id
          end
          nil
        end

        private

        def entries_to_hash(entries)
          result = {}
          entries.each do |entry|
            result[entry.id] = entry
          end
          result
        end

        def get_users
          entries = ::User.where(id: @objects.map(&:user_id).uniq)
          entries_to_hash(entries)
        end

        def get_machines
          user_ids = (@users || get_users).keys.uniq
          entries = Tmt::Machine.where(user_id: user_ids)
          entries_to_hash(entries)
        end

      end
    end
  end
end
