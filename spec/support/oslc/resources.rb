module Support
  module Oslc
    module Resources
      shared_examples_for "Resources class of OSLC" do
        let(:project) { raise "'project' method isn't defined." }
        let(:first_resource) { raise "'first_resource' method isn't defined." }
        let(:second_resource) { raise "'second_resource' method isn't defined." }
        let(:foreign_resource) { raise "'foreign_resource' method isn't defined." }
        let(:testing_class) { raise "'testing_class' method isn't defined." }

        def identifier_for(resource)
          raise "'identifier_for' method isn't defined"
        end

        before do
          ready(first_resource, project, second_resource, foreign_resource)
          first_resource.class.should have(3).items
          first_resource.class.all.should match_array([
            first_resource, second_resource, foreign_resource
          ])
        end

        it "shows records for correct identifier" do
          result = rdf("dcterms:identifier=\"#{identifier_for(first_resource)}\"")
          result.to_xml.should include identifier_with_tag_for(first_resource)
          result.to_xml.should_not include identifier_with_tag_for(second_resource)
          result.to_xml.should_not include identifier_with_tag_for(foreign_resource)
        end

        it "shows records for correct project" do
          result = rdf('')
          result.to_xml.should include identifier_with_tag_for(first_resource)
          result.to_xml.should include identifier_with_tag_for(second_resource)
          result.to_xml.should_not include identifier_with_tag_for(foreign_resource)
        end

        it "shows empty list of records when wasn't defined any records" do
          first_resource.delete
          second_resource.delete
          foreign_resource.class.all.should match_array [foreign_resource]
          result = rdf('')
          result.xpath('//rdf:Description').should have(1).item
        end

        it "shows only title for all resources" do
          result = rdf('', 'dcterms:modified')
          result.xpath('//dcterms:modified').should have(2).items
          result.xpath('//dcterms:identifier').should have(0).items
        end

        private

        def rdf(oslc_where, oslc_select=nil)
          content = testing_class.new({
            oslc_where: oslc_where,
            oslc_select: oslc_select,
            provider: project
          }).to_rdf
          Nokogiri::XML(content)
        end

        def identifier_with_tag_for(resource)
          "<dcterms:identifier rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">#{identifier_for(resource)}</dcterms:identifier>"
        end
      end
    end
  end
end
