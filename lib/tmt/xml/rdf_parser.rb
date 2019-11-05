module Tmt
  class XML
    class RDFParser

      attr_accessor :nodes, :result, :id

      def initialize(nodes=[], options={})
        @nodes = nodes
        @result = ""
        @id = 0
        if options[:ancestor]
          @ancestor = options[:ancestor]
        else
          @ancestor = self
        end
      end

      def to_s
        parse
        @result
      end

      protected

      def get_id
        @ancestor.id ||= 0
        @ancestor.id = @ancestor.id + 1
      end

      def parse
        @nodes.each do |node|
          if node.selector =~ /:[A-Z]/
            rdf_parser = self.class.new(node.nodes, {ancestor: @ancestor})
            rdf_parser.parse
            type = ::Tmt::XML::Base.vocabulary_type_url(node.selector)
            @ancestor.result << %Q{<rdf:Description rdf:about="#{node.rdf_about}">#{rdf_parser.result}<rdf:type rdf:resource="#{type}"/></rdf:Description>}
          elsif node.selector =~ /:[a-z]/
            if node.nodes.any?
              rdf_parser = self.class.new(node.nodes[0].nodes, {ancestor: @ancestor})
              rdf_parser.parse
              rdf_about = node.nodes[0].rdf_about
              type = ::Tmt::XML::Base.vocabulary_type_url(node.nodes[0].selector)
              if rdf_about.nil?
                id = get_id
                @result << %Q{<#{node.selector} rdf:nodeID="node#{id}"/>}
                @ancestor.result << %Q{<rdf:Description rdf:nodeID="node#{id}">#{rdf_parser.result}<rdf:type rdf:resource="#{type}"/></rdf:Description>}
              else
                @result << %Q{<#{node.selector} rdf:resource="#{rdf_about}"/>}
                @ancestor.result << %Q{<rdf:Description rdf:about="#{rdf_about}">#{rdf_parser.result}<rdf:type rdf:resource="#{type}"/></rdf:Description>}
              end
            else
              @result << node.to_xml
            end
          end
        end
      end

    end
  end
end
