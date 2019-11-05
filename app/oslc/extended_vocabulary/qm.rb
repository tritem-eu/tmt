module Oslc
  class ExtendedVocabulary
    class Qm
      def initialize(controller)
        @controller = controller
      end

      def to_xml
        Tmt::XML::RDFXML.new(xmlns: {
          dcterms: :dcterms,
          rdf: :rdf,
          rdfs: :rdfs,
          owl: :owl
        }) do |xml|
          xml.add('owl:Ontology', rdf: {about: url_with}) do |xml|
            xml.add('dcterms:title') { 'The Tmt Quality Management Vocabulary' }
            xml.add('rdfs:label') { 'Quality Management(QM)' }
          end
          xml.add('rdfs:Class', rdf: {about: url_with('TestPlanCustomField')}) do |xml|
            xml.add('rdfs:isDefinedBy', rdf: {resource: url_with})
            xml.add('rdfs:label') {'TestPlanCustomField'}
            xml.add('rdfs:common') {'The QM Test Plan Custom Field resource'}
          end
          xml.add('rdf:Property', rdf: {about: url_with('usesTestPlanCustomField')}) do |xml|
            xml.add('rdfs:isDefinedBy', rdf: {resource: url_with})
            xml.add('rdfs:label') { 'usesTestPlanCustomField' }
            xml.add('rdfs:label') { 'usesTestExecutionRecord' }
            xml.add('rdfs:label') { 'usesTestResult' }
            xml.add('rdfs:comment') { 'Test Plan Custom Field used by the Test Plan. It is likely that the target resource will be an tmt_qm:TestPlanCustomField but that is not necessarily the case' }
            xml.add('rdfs:range', rdf: {resource: url_with('TestPlanCustomField')})
          end
        end.to_xml
      end

      private

      def url_with(string="")
        "#{::Tmt::XML::Base.vocabulary_url(:oslcev_qm)}#{string}"
      end
    end
  end
end
