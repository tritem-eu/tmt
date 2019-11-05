# Documentation:
#   http://open-services.net/bin/view/Main/OSLCCoreSpecQuery
#   https://www.theseus.fi/bitstream/handle/10024/52794/Katajamaki_Joni.pdf?sequence=1
# Examples:
#   http://open-services.net/bin/view/Main/OslcSimpleQuerySyntaxV1
#   http://open-services.net/bin/view/Main/OslcSimpleQuerySemanticsV1
#   http://dev.eclipse.org/mhonarc/lists/lyo-dev/msg00390.html
#   http://pic.dhe.ibm.com/infocenter/tivihelp/v3r1/index.jsp?topic=%2Fcom.ibm.psc.doc_1.1.0.1%2Frs_original%2Ftshoot%2Frs_c_ts_useful_registry_srvc_query.html
#   https://jazz.net/library/content/articles/rtc/3.0/oslc-workshop/rsc/2011-08-19-OSLC-CM-workshop.pdf
#
# Type of data
#   http://www-01.ibm.com/support/knowledgecenter/SSEKCU_1.1.0/com.ibm.psc.doc_1.1.0/rs_original/oslc/web/rs_r_xsd_data_type.html?lang=en
#
# http://www-01.ibm.com/support/knowledgecenter/SSSHYH_7.1.0/com.ibm.netcoolimpact.doc_7.1/solution/oslc_query_syntax_c.html
#   * oslc.properties query parameter
#       Use the oslc.properties query parameter to display the properties for an individual resource URI that does not contain any rdfs:member lists
#   * oslc.select query parameter
#       If the identifiers that you want to limit the properties of belong to a member list for a resource, use the oslc.select query parameter.
#
# getting started:
# - model
#   Example:
#     model name:
#       DummyModel
#     resource class:
#       class Oslc::DummyModel < Oslc::Core::Resource
#         add_selector 'rdf:type', :rdf_resource do
#           [{rdf: {resource: "http://localhost:3000"}}]
#         end
#         add_selector 'dcterms:identifier', :int do
#           [{}, 23]
#         end
#
#         def self.namespaces
#           {
#             rdf: :rdf,
#             dcterms: :identifier
#           }
#         end
#       end
#     query syntax class:
#       class Oslc::DummyModel::QuerySyntax < Oslc::Core::QuerySyntax
#          def initialize(options={})
#            @all_entries = @class_name.all
#            @resource_class = ::Oslc::DummyModel
#            @selector_for_entry = "oslc_auto:automationAdapter"
#          end
#
#         def namespaces
#           ::Oslc::DummyModel.namespaces.merge({
#             rdfs: :rdfs
#           })
#         end
#
#         def entry_url(entry)
#           @controller.example_url(@provider, entry)
#         end
#       end
module Oslc
  module Core
    class Query
      require_relative 'query/literal_value'

      attr_accessor :routes, :class_name
      attr_reader :sql_joins

      @@dictionary = {}

      def self.define_property selector, &options
        @@dictionary[self] ||= {}
        @@dictionary[self][selector] = options
      end

      def initialize(options={})
        @class_name = nil
        @options = options
        @@routes = ::Oslc::Core::Routes.get_singleton
        @url_parser = ::Oslc::Core::UrlParser.new()
        @dictionary = {}
        @@dictionary[self.class].each do |key, proc|
          @dictionary[key] = proc.call
        end
        @sql_joins = options[:sql_joins] || {}
        after_initialize
      end

      # input:
      #   syntax - string of query (oslc standard)
      # output:
      #   objects array
      # Give me the bugs with identifier 4242
      #   http://example.com/bugs?oslc.where=dcterms:identifier="4242“
      # Give me the bugs with "high priority" created after April 2010
      #   http://example.com/bugs?oslc.where=cm:severity="high" and dcterms:created>"2010-04-01
      # Give me the bugs created by "Jhon Smith"
      #   http://example.com/bugs?oslc.where=dcterms:creator{foaf:givenName="John" and foaf:familyName="Smith"}
      def where(syntax = @oslc_where)
        # When oslc_where variable isn't defined
        if syntax.blank?
          @where
        else
          compound_term(syntax) || []
        end
      end

      def get_ids_from_url(url, pattern)
        elements = pattern.split('*')
        result = url
        elements.each do |sub_url|
          result = result.sub(sub_url, '*')
        end
        result.split('*').delete_if{ |item| item == ''}
      end

      def compound_term(syntax)
        return if syntax.nil?
        split_and(syntax).each do |value|
          simple_term = simple_term(value)
          @where = @where.where(simple_term) if simple_term
        end
        begin
          @where if @where.size >= 0
        rescue
          nil
        end
      end

      protected

      def simple_term(syntax)
        unless syntax =~ /[\w:\w]+{.*}$/
          term(syntax)
        else
          scope_term(syntax)
        end
      end

      # Input:
      #   content: simple_term (space? and space? simple_term)*
      # Return:
      #   array of splited content by ' and '
      def split_and(content)
        result = []
        return result if content.blank?
        open_brackets = 0
        count_down = -1
        sub_content = ''
        content.size.times do |index|
          char = content[index]
          open_brackets += 1 if '{' == char
          open_brackets -= 1 if '}' == char
          count_down -= 1
          if ' and ' == content[index, 5] and 0 == open_brackets
            result << sub_content
            sub_content = ''
            count_down = 4
          else
            sub_content << char if count_down < 0
          end
        end
        result << sub_content
        result
      end

      def term(syntax)
        case syntax
        when /[\*|\w:\w]+=/
          comparison_op(syntax, "=", :eq)
        when /[\*|\w:\w]+!=/
          comparison_op(syntax, "!=", :eq).not
        when /[\*|\w:\w]+<=/
          comparison_op(syntax, "<=", :lteq)
        when /[\*|\w:\w]+</
          comparison_op(syntax, "<", :lt)
        when /[\*|\w:\w]+>=/
          comparison_op(syntax, ">=", :gteq)
        when /[\*|\w:\w]+>/
          comparison_op(syntax, ">", :gt)
        when /[\*|\w:\w]+ in/
          identifier_wc, in_val = syntax.split(/ in | in/, 2)
          in_val = in_val.gsub(/^\[|\]$/, "").split(",").map{|element| parse_to_value(identifier_wc, element)}
          unless identifier_wc == "*"
            if @dictionary[identifier_wc][:model_attribute]
              @class_name.arel_table[@dictionary[identifier_wc][:model_attribute]].in(in_val)
            else
              nil
            end
          else
            ## TODO
          end
        else
          raise "Invalid query of syntax '#{syntax}'"
        end
      end

      def comparison_op(syntax, operator, arel_method)
        identifier_wc, raw_value = syntax.split(operator, 2)
        unless identifier_wc == "*"
          if @dictionary[identifier_wc][:model_attribute]
            parsed_value = parse_to_value(identifier_wc, raw_value)
            if parsed_value.class == Array
              arel_method = 'in'
            end
            unless parsed_value == :all
              @class_name.arel_table[@dictionary[identifier_wc][:model_attribute]].send(arel_method, parsed_value)
            end
          else
            nil
          end
        else
          ## TODO
          #@dictionary.each do |identifier_wc|
          #  if attribute(identifier_wc)
          #    @class_name.arel_table[attribute[identifier_wc]].send(arel_method, parse_to_value(identifier_wc, raw_value))
          #  end
          #end
        end
      end

      def attribute(selector)
        @dictionary[selector][:model_attribute]
      end

      def parse_identifier(prefix_name, value)
        url_pattern = @dictionary[prefix_name][:url_pattern]
        self.get_ids_from_url(value, url_pattern)[1]
      end

      def parse_to_value(prefix_name, value)
        original_value = value
        # http://open-services.net/bin/view/Main/OslcSelectiveProperties#uri_ref_esc
        if value.to_s.strip =~ /^<.*>$/ # uri_ref_esc
          run_parser_for_prefix_name(prefix_name, value)
        else
          value = Oslc::Core::Query::LiteralValue.new(value.strip).parse
          if value.nil?
            raise "Invalid value: #{original_value} for prefixed_name: #{prefix_name}"
          end
          case @dictionary[prefix_name][:parser]
          when :int
            value.to_i
          when :date
            value.in_time_zone.utc
          when :text
            value
          when :string
            value
          when :boolean
            value.to_s == 'true' ? true : false
          else
            run_parser_for_prefix_name(prefix_name, value)
          end
        end
      end

      def run_parser_for_prefix_name(prefix_name, value)
        parser = @dictionary[prefix_name][:parser]
        if parser.class == Proc
          self.instance_exec value, &parser
        else
          if self.methods.include?(parser)
            self.method(parser).call(prefix_name, value)
          else
            raise "Didn't defined parser for selector '#{prefix_name}'"
          end
        end
      end

      def scope_term(syntax)
        identifier_wc, compound_term = syntax.strip.scan(/([\w:\w]+)\{(.*)\}/).first
        attribute = @dictionary[identifier_wc]
        unless attribute[:query_class]
          raise "Doesn't define 'query_class' option for '#{identifier_wc}' attribute."
        end
        sql_joins = @sql_joins

        if attribute[:joins]
           attribute[:joins].each do |name|
            unless sql_joins[name]
              sql_joins[name] = {}
            end
            sql_joins = sql_joins[name]
          end
        end
        sub_query = attribute[:query_class].new(provider: @provider, sql_joins: sql_joins)
        result = sub_query.simple_term(compound_term)
        @where = @where.joins(@sql_joins)
        result
      end
    end
  end
end
