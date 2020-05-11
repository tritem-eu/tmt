module ActionDispatch
  module Routing
    module PolymorphicRoutes
      class HelperMethodBuilder
        def self.polymorphic_method(recipient, record_or_hash_or_array, action, type, options)
          builder = get action, type
          case record_or_hash_or_array
          when Array
            record_or_hash_or_array = record_or_hash_or_array.compact
            if record_or_hash_or_array.empty?
              raise ArgumentError, "Nil location provided. Can't build URI."
            end
            if record_or_hash_or_array.first.is_a?(ActionDispatch::Routing::RoutesProxy)
              recipient = record_or_hash_or_array.shift
            end

            method, args = builder.handle_list record_or_hash_or_array
          when String, Symbol
            method, args = builder.handle_string record_or_hash_or_array
          when Class
            method, args = builder.handle_class record_or_hash_or_array

          when nil
            raise ArgumentError, "Nil location provided. Can't build URI."
          else
            method, args = builder.handle_model record_or_hash_or_array
          end
          method = method.gsub("tmt_", "").gsub("tmt_", "")
          if options.empty?
            recipient.send(method, *args)
          else
            recipient.send(method, *args, options)
          end
        end
      end
      
    end
  end
end
