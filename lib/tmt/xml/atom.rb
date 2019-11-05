require_relative "base"

# Example:
#   http://open-services.net/bin/view/Main/OSLCCoreSpecAtomExamples#Query_Resource
module Tmt
  class XML
    class Atom < ::Tmt::XML::Base
      def initialize(params={}, &block)
        params[:xmlns] ||= {}
        params[:xmlns][nil] = 'http://www.w3.org/2005/Atom'
        super('feed', params)
        block.call(self) if block_given?
      end

      def to_xml
        rdfxml = super do
          result = ""
          @nodes.each do |node|
            result += "#{node.to_xml}"
          end
          result
        end
        pretty(rdfxml)
      end

    end
  end
end
