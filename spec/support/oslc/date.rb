module Support
  module Oslc
    class Date
      DATETIME_PRECISION = 6
      def initialize(data)
        @data = data
      end

      def iso8601
        @data.utc.iso8601(DATETIME_PRECISION)
      end
    end
  end
end
