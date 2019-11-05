# Type of data
#   http://www-01.ibm.com/support/knowledgecenter/SSEKCU_1.1.0/com.ibm.psc.doc_1.1.0/rs_original/oslc/web/rs_r_xsd_data_type.html?lang=en
module Oslc
  module Core
    class Query
      class LiteralValue

        def initialize(raw_value)
          @raw_value = raw_value.strip
        end

        def parse
          result = nil
          result ||= parse_if_boolean
          result ||= parse_if_decimal
          result ||= parse_if_string_esc
          result ||= parse_if_string_esc_with_prefixed_name
          result ||= parse_if_string_esc_with_langtag
          result
        end

        private

        def parse_if_string_esc_with_prefixed_name
          return nil unless  @raw_value =~ /^".*"\^\^(xsd|rdf):[a-zA-Z]+$/
          value, prefix_name = @raw_value.scan(/^(".*)"\^\^((xsd|rdf):[a-zA-Z]+)$/).flatten
          value = value.gsub(/^"|"$/, '')
          case prefix_name
          when "xsd:boolean"
            return value if ['true', 'false'].include? value
          when "xsd:anyUri"
            return "<" + value + '>'
          when "xsd:string"
            return value
          when "rdf:XMLLiteral"
            return value
          when "xsd:integer"
            return value.to_i if value =~ /^[-+]?[0-9]+$/
          when "xsd:decimal"
            return value.to_f if value_is_decimal?(value)
          when "xsd:double", 'xsd:float'
            return value.to_f if value =~ /^[-+]?([0-9]+\.[0-9]*|\.[0-9]+|[0-9]+)[eE][-+]?[0-9]+$/
          when "xsd:dateTime"
            return value
          else
            return nil
          end
        end

        def parse_if_string_esc
          @raw_value.scan(/^"(.*)"$/).flatten[0]
        end

        def parse_if_string_esc_with_langtag
          @raw_value.scan(/^"(.*)"@[a-zA-Z]+(-[a-zA-Z0-9]+)*$/).flatten[0]
        end

        def parse_if_boolean
          if 'true' == @raw_value
            return 'true'
          end
          if 'false' == @raw_value
            return 'false'
          end
        end

        def parse_if_decimal
          return @raw_value.to_f if value_is_decimal? @raw_value
        end

        def value_is_decimal?(value)
          value =~ /^[-+]?[0-9]*\.?[0-9]+$/
        end

      end
    end
  end
end
