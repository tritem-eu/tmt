module Tmt
  module Lib
    # This class helps arrange nested object some like 'file system'
    class Nesting

      def initialize
        @current_position = -1
        @array = []
        @limit_array = []
      end

      def budget_in(array)
        @array[@current_position] ||= 0

        unless array.nil?
          @array[@current_position] += array.size
        end
        @limit_array[@current_position] = @array[@current_position]
      end

      def increment_nesting
        @current_position += 1
      end

      def decrement_nesting
        @current_position -= 1
        @current_position = 0 if @current_position < 0
      end

      def decrement_counter
        @array[@current_position] -= 1
        @array[@current_position] = 0 if @array[@current_position] < 0
      end

      def set_numbers
        @array
      end

      def generate_indent
        result = ''
        @current_position.times do |index|
          unless @array[index] == 0
            result << span_tag('', style: 'width: 1px; display: inline-block')
            result << span_tag('│', style: 'width: 37px; display: inline-block')
          else
            result << span_tag('', style: 'width: 38px; display: inline-block')
          end
        end
        if @array[@current_position] > 0
          result << '├──'
        else
          result << '└──'
        end
        span_tag(result, style: 'color: #dedede')
      end

    private

      def span_tag content=nil, options={}
        "<span style='#{options[:style]}' class='#{options[:class]}'>#{content}</span>"
      end
    end
  end
end
