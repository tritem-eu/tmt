module Support
  module Oslc
    module Controllers
      module Resources
        # For example:
        # include Support::Oslc::Controllers::Resources
        # let(:project) do
        #   project = create(:project)
        #   project.add_member(user)
        #   project
        # end
        # it_should_behave_like "Get query for OSLC resource" do
        #   let(:type) { 'oslc_qm:TestCase' }
        #   let(:user_to_log) { user }
        #   let(:foreign_resource) { ... }
        #   let(:resources_from_project) { [..., ...] }
        #   let(:dcterms_identifier) { "URL of one of resource from resource_from_project"}
        # end
        shared_examples_for "GET query for OSLC resources" do
          let(:xml) { Nokogiri::XML(response.body) }

          def resource_type(format)
            if format == :rdf
              Tmt::XML::Base.vocabulary_type_url(type)
            elsif format == :xml
              type
            end
          end

          [
            ['application/rdf+xml', :rdf],
            ['application/xml', :xml]
          ].each do |accept, format|
            describe "GET query for format #{format} (The User isn't logged)" do
              it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic) do |options|
                request.headers['accept'] = accept
                get :query, service_provider_id: project.id
              end
            end

            describe "GET query for format #{format} when is used oslc.select and oslc.where params" do
              before do
                ready(resources_from_project, foreign_resource)
                http_login(user_to_log)
                request.headers['accept'] = accept
                get :query, service_provider_id: project.id, 'oslc.select' => 'dcterms:modified', 'oslc.where' => "dcterms:identifier=<#{dcterms_identifier}>"
              end

              it "shows only properties defined in 'oslc.select' options" do
                response.body.should include(resource_type(format))
                xml.xpath('//dcterms:identifier').should be_empty
                xml.xpath('//dcterms:modified').should_not be_empty
              end

              it "shows only one resource which is defined in 'oslc.where' options" do
                xml.xpath('//dcterms:modified').should have(1).item
              end

              it 'sends 200 status code' do
                response.status.should eq(200)
              end
            end

            describe "GET query for format #{format} when isn't used oslc.select and oslc.where params" do
              before do
                ready(resources_from_project, foreign_resource)
                http_login(user_to_log)
                request.headers['accept'] = accept
                get :query, service_provider_id: project.id
              end

              it "shows only resources from project" do
                response.body.should include(resource_type(format))
                xml.xpath('//dcterms:identifier').should have(resources_from_project.size).item
              end

              it 'sends 200 status code' do
                response.status.should eq(200)
              end
            end

          end

        end
      end
    end
  end
end
