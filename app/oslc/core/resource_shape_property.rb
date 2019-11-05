module Oslc
  module Core
    class ResourceShapeProperty

      def initialize
        @values = {}
      end

      def property_definition(value)
        @values[:property_definition] = value
      end

      def occurs(value)
        @values[:occurs] = value
      end

      def description(value)
        @values[:description] = value
      end

      def hidden(value)
        @values[:hidden] = value
      end

      def title(value)
        @values[:title] = value
      end

      def is_member_property(value)
        @values[:is_member_property] = value
      end

      def name(value)
        @values[:name] = value
      end

      def read_only(value)
        @values[:read_only] = value
      end

      def value_type(value)
        @values[:value_type] = value
      end

      def representation(value)
        @values[:representation] = value
      end

      def range(value)
        @values[:range] = value
      end

      def value_shape(value)
        unless value == nil
          value = ::Tmt::XML::Base.vocabulary_type_url(value)
        end
        @values[:value_shape] = value
      end

      def to_name(property_name)
        property_name.split(':')[1]
      end

      def to_title(property_name)
        to_name(property_name).gsub(/(.)([A-Z])/,'\1_\2').split('_').map(&:capitalize).join(' ')
      end

      def values
        property_name = @values[:property_definition]
        @values[:title] = @values[:title] || to_title(property_name)
        @values[:name] = @values[:name] || to_name(property_name)
        @values
      end

    end
  end
end
