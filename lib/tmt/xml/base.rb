module Tmt
  class XML
    class Base
      require "nokogiri"

      attr_reader :nodes, :content, :selector

      def initialize selector, params={}
        @rdf = params[:rdf] || {}
        @xmlns = params[:xmlns] || {}
        @xml = params[:xml] || {}
        @selector = selector
        @nodes = []
        @content = nil
        if block_given?
          @content = yield(self)
        end
      end

      def rdf_about
        @rdf[:about]
      end

      # render object into RDF/XML
      # validator: http://www.rdfabout.com/demo/validator/
      def to_xml
        result = ''
        if not @nodes == []
          result = @nodes.map(&:to_xml).join
        else
          result = @content
        end

        if result.blank?
          result = %Q{<#{@selector}#{xmlns}#{rdf}#{xml} />}
        else
          result = %Q{<#{@selector}#{xmlns}#{rdf}#{xml}>#{result}</#{@selector}>}
        end
        result
      end

      def to_rdf
        to_xml
      end

      def add selector, params={}
        property = ::Tmt::XML::Base.new(selector, params) do |handler|
          if block_given?
            yield(handler)
          end
        end
        @nodes << property
        property
      end

      # Examples:
      #   Base.vocabulary_type_url("oslc:Resource") #=> "http://open-services.net/ns/core#Resource"
      #   Base.vocabulary_type_url("rdfs:boolean") #=> "http://www.w3.org/2001/XMLSchema#boolean"
      #   Base.vocabulary_type_url("http://purl.org/dc/terms/status") #=> "http://purl.org/dc/terms/status"
      def self.vocabulary_type_url(selector)
        if selector =~ /^http.*/
          selector
        else
          vocabulary_key, type = selector.split(":")
          [vocabulary_url(vocabulary_key.to_sym), type].join("")
        end
      end

      def vocabulary_type_url(selector)
        self.class.vocabulary_type_url(selector)
      end

      def pretty(string)
        ::Nokogiri::XML(string).to_xml(encoding: 'utf-8')
      end

      private

      # Add addition attributes for vocabulary rdf
      # Example:
      #   #<Base:id @rdf = {about: "http://example.com"}>
      #   #<Base:id>.rdf #=> %Q{rdf:about="http://example.com"}
      def rdf
        result = ""
        @rdf.each do |attribute, value|
          result << %Q{ rdf:#{attribute}="#{value}"}
        end
        result
      end

      # Return prefixes of xml to main tag
      def xmlns
        result = ""
        @xmlns.each do |key, url|
          if key == nil
            result << %Q{ xmlns="#{self.class.vocabulary_url(url)}"}
          else
            result << %Q{ xmlns:#{key}="#{self.class.vocabulary_url(url)}"}
          end
        end
        result
      end

      def xml
        result = ""
        @xml.each do |key, value|
          result << %Q{ xml:#{key}="#{value}"}
        end
        result
      end

      # Return url of vocabulary for key
      # Example:
      #   self.vocabulary_url(:rdf) #=> "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      #   self.vocabulary_url("http://www.example.com#") #=> "http://www.example.com#"
      def self.vocabulary_url(key_or_url)
        if key_or_url.class == Symbol
          result = {
            acp: "http://jazz.net/ns/acp#",
            dcterms: "http://purl.org/dc/terms/",
            foaf: "http://xmlns.com/foaf/0.1/",
            jfs: "http://jazz.net/xmlns/prod/jazz/jfs/1.0/",
            rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            rdfs: "http://www.w3.org/2000/01/rdf-schema#",
            rqm_auto: 'http://jazz.net/ns/auto/rqm#',
            rqm_qm: 'http://jazz.net/ns/qm/rqm#',
            #oslcev_qm: "http://#{ActionMailer::Base.default_url_options[:host]}/oslc-extended-vocabulary/qm/",
            oslc_auto: "http://open-services.net/ns/auto#",
            oslc_cm: "http://open-services.net/xmlns/cm/1.0/",
            oslc_rm: "http://open-services.net/xmlns/rm/1.0/",
            oslc_qm: "http://open-services.net/ns/qm#",
            oslcev_qm: "http://open-services.net/ns/qm#",
            oslc: "http://open-services.net/ns/core#",
            owl: 'http://www.w3.org/2002/07/owl#',
            xmls: "http://www.w3.org/2001/XMLSchema#"
          }[key_or_url]
          raise "Didn't define key '#{key_or_url}'" if result.nil?
          result
        else
          key_or_url
        end
      end
    end
  end
end
