# encoding: utf-8

module Tmt
  module Lib
    class ExtendedActiveRecord
      def self.extract_for(collection, attribute=:id)
        result = {}
        if collection
          collection.each do |entry|
            result[entry.id] = entry
          end
        end
        result
      end
    end
  end
end
