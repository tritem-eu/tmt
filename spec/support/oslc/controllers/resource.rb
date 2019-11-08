module Support
  module Oslc
    module Controllers
      module Resource
        extend CanCanHelper

        # For example:
        # include Support::Oslc::Controllers::Resource
        # let(:project) do
        #   project = create(:project)
        #   project.add_member(user)
        #   project
        # end
        # it_should_behave_like "Get 'show' for OSLC resource" do
        #   let(:resource) { ... } # this resource must be included to project (for example: Tmt::TestCase, Tmt::TestRun)
        #   let(:type) { 'oslc_qm:TestCase' }
        #   let(user_to_log) { user }
        # end
        shared_examples_for "GET 'show' for OSLC resource" do
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
          ].each do |request_accept, format|
            describe "for format #{format} (The User isn't logged)" do
              it_should_not_authorize(self, [:no_logged, :foreign], auth: :basic, format: format) do |options|
                ready(project, user_to_log, resource)
                request.headers['accept'] = request_accept
                get :show, id: resource.id, service_provider_id: project.id
              end
            end

            describe "for format #{format}" do

              before do
                ready(project, resource, user_to_log)
                http_login(user_to_log)
                request.headers['accept'] = request_accept
                get :show, id: resource.id, service_provider_id: project.id, 'oslc.properties' => 'dcterms:modified'
              end

              it "should show rdf:RDF class" do
                xml.xpath('//rdf:RDF').text().should_not be_empty
              #  response.body.should include(resource_type(format))
              end

              it "should show only 'dcterms:modified' property" do
                xml.xpath('//dcterms:identifier').should be_empty
                xml.xpath('//dcterms:modified').should_not be_empty
              end

              it "should send 200 status code" do
                response.status.should eq(200)
              end
            end
          end
        end
      end
    end
  end
end
