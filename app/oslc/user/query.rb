# Automation Request Query

module Oslc
  module User
    class Query < Oslc::Core::Query

      define_property "foaf:name" do
        {
          parser: :string,
          model_attribute: :name
        }
      end

      define_property "foaf:mbox" do
        parser = lambda do |value|
          value.gsub(/^mailto:/, '')
        end
        {
          parser: parser,
          model_attribute: :email
        }
      end

      def after_initialize
        @class_name = ::User
        @provider = @options[:provider]
        @where = @class_name.undeleted
      end

    end
  end
end
