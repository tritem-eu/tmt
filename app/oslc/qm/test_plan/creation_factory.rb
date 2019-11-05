# A Test Plan Query

# http://publib.boulder.ibm.com/infocenter/tivihelp/v8r1/index.jsp?topic=%2Fcom.ibm.netcoolimpact.doc6.1.1%2Fsolution%2Foslc_query_oslc_select_c.html
module Oslc
  module Qm
    module TestPlan
      class CreationFactories
        def class_name
          ::Tmt::TestRun
        end

        def parse(content)

          Tmt::XML::RDFXML.new(xmlns: {
            dcterms: :dcterms,
            rdf: :rdf,
            oslc_qm: :oslc_qm,
            oslc_cm: :oslc_cm,
            rdfs: :rdfs,
            oslc: :oslc
          }, xml: {lang: :en}) do |xml|
            @query.where.each do |entry|
              xml.add("rdf:Description") do |xml|
                xml
              end
            end
          end.to_xml
        end
      end
    end
  end
end
