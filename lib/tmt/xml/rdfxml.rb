require_relative "base"

module Tmt
  class XML
    class RDFXML < ::Tmt::XML::Base
      def initialize params={}
        super('rdf:RDF', params)
        @params = params
      end

      def to_xml
        rdfxml = super do
          @nodes.map(&:to_xml).join
        end
        pretty(rdfxml)
      end

      def to_rdf
        result = ::Tmt::XML::Base.new('rdf:RDF', @params) do
          ::Tmt::XML::RDFParser.new(@nodes).to_s
        end.to_rdf
        pretty(result)
      end
    end
  end
end
