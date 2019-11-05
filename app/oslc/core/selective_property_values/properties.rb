module Oslc
  module Core
    class SelectivePropertyValues
      class Properties
        def initialize(oslc_properties, options={})
          @oslc_properties = oslc_properties
          @parse = nil
        end

        # For @oslc_properties = 'dcterms:title,dcterms:creator{foaf:givenName}')
        # self.parse #=> [
        #   ['dcterms:title'],
        #   ['dcterms:creator'],
        #   ['dcterms:creator', 'foaf:givenName'],
        # ]
        def parse
          return nil if @oslc_properties.nil?
          return @parse if @parse
          @parse ||= []
          properties.each do |property|
            case property
            when /\A[a-zA-Z]+:[a-zA-Z]+\{.*\}\Z/ # nested_prop
              property, nested_prop = property.scan(/\A([a-zA-Z]+:[a-zA-Z]+)\{(.*)\}\Z/).flatten
              @parse << [property] unless property.blank?

              self.class.new(nested_prop).parse.each do |selector|
                @parse << [property] + selector
              end
            else # identifier / wildcard
              @parse << [property] unless property.blank?
            end
          end
          @parse
        end

        private

        # Return array of selectors divided by ','
        # For example:
        #   @oslc_properties = dcterms:title,dcterms:creator{foaf:givenName,foaf:familyName},dcterms:identifier')
        #   self.parse #=> [
        #                    "dcterms:title",
        #                    "dcterms:creator{foaf:givenName,foaf:familyName}",
        #                    "dcterms:identifier"
        #                  ]
        def properties
          amount_bracket = 0
          result = []
          sub_code = ""
          @oslc_properties.each_char do |char|
            amount_bracket += 1 if '{' == char
            amount_bracket -= 1 if '}' == char

            if amount_bracket == 0 and ',' == char
              result << sub_code
              sub_code = ''
            else
              sub_code << char
            end
          end
          result << sub_code
          result
        end
      end
    end
  end
end
