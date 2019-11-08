require 'spec_helper'

describe Oslc::Qm::TestCasesController do
  extend CanCanHelper
  include Support::Oslc::Controllers::Resource
  include Support::Oslc::Controllers::Resources

  let(:admin) { create(:admin) }

  let(:user) { create(:user) }

  let(:valid_attributes) { { "name" => "MyString", creator_id: admin.id } }

  let(:project) do
    project = create(:project, valid_attributes)
    project.add_member(user)
    project
  end

  let(:test_case) do
    create(:test_case_with_type_file,
      project: project,
      description: "Description of test case"
    )
  end

  let(:xml) { Nokogiri::XML(response.body) }

  before do
    ready(project, user)
  end

  describe "POST creation_dialog" do
    it "creates a new Tmt::TestCase" do
      http_login(user)
      expect {
        post :creation_dialog, {service_provider_id: project.id, :test_case => {name: 'example'}}
      }.to change(Tmt::TestCase, :count).by(1)
    end
  end

  it "GET #selection_dialog" do
    http_login(user)
    get :selection_dialog, service_provider_id: project.id
    assigns(:response).should match(/oslc-response:/)
  end

  it_should_behave_like "GET 'show' for OSLC resource" do
    let(:type) {"oslc_qm:TestCase"}
    let(:user_to_log) { user }
    let(:resource) do
      test_case
    end
  end

  it_should_behave_like "GET query for OSLC resources" do
    let(:type) {"oslc_qm:TestCase"}
    let(:user_to_log) { user }
    let(:resources_from_project) do
      [
        test_case,
        create(:test_case, project: project)
      ]
    end
    let(:foreign_resource) do
      create(:test_case)
    end
    let(:dcterms_identifier) do
      server_url "/oslc/qm/service-providers/#{project.id}/test-results/#{test_case.id}"
    end
  end

  [
    ['application/rdf+xml', :rdf],
    ['application/xml', :xml]
  ].each do |content_type, format|
    describe "POST create for format #{format}" do
      let(:valid_content) do
        Tmt::XML::RDFXML.new(xmlns: {
          dcterms: :dcterms,
          rdf: :rdf,
        }, xml: {lang: :en}) do |xml|
          xml.add("dcterms:description") { "Description of resource" }
          xml.add("dcterms:title") { "Title of resource" }
        end.to_xml
      end

      let(:invalid_content) do
        Tmt::XML::RDFXML.new(xmlns: {
          dcterms: :dcterms,
          rdf: :rdf,
        }, xml: {lang: :en}) do |xml|
          xml.add("dcterms:description") { "Description of resource" }
          xml.add("dcterms:title") { "" }
        end.to_xml
      end

      before do
        http_login(user)
        ready(project)
      end

      it "should create new a test case when content is properly" do
        expect do
          post :create, valid_content, content_type: content_type, service_provider_id: project.id, format: format
        end.to change(Tmt::TestCase, :count).by(1)
      end

      it "render xml content with id of new test case" do
        post :create, valid_content, content_type: content_type, service_provider_id: project.id, format: format
        Tmt::TestCase.last
        xml.xpath('//dcterms:identifier').text.should eq(Tmt::TestCase.last.id.to_s)
        response.status.should eq(201)
      end

      it "should not create new a test case when content has got blank name" do
        expect do
          post :create, invalid_content, content_type: content_type, service_provider_id: project.id, format: format
        end.to change(Tmt::TestCase, :count).by(0)
      end

      it "render xml content with message about invalid operation" do
        post :create, invalid_content, content_type: content_type, service_provider_id: project.id, format: format
        xml.xpath('//oslc:statusCode').text.should eq('400')
        xml.xpath('//oslc:message').text.should eq("Name can't be blank. Name does not have length between 1 and 40")
        response.status.should eq(400)
      end

      it "render status 400 when content is blank" do
        post :create, '', content_type: content_type, service_provider_id: project.id, format: format
        xml.xpath('//oslc:statusCode').text.should eq('400')
        xml.xpath('//oslc:message').text.should eq("Undefined namespace prefix: //dcterms:description")
        response.status.should eq(400)
      end

    end
  end

  describe "PUT update" do

    let(:test_case) { create(:test_case, project: project) }

    let(:valid_content) do
      Tmt::XML::RDFXML.new(xmlns: {
        dcterms: :dcterms,
        rdf: :rdf,
      }, xml: {lang: :en}) do |xml|
        xml.add("dcterms:description") { "New description" }
        xml.add("dcterms:title") { "New Title" }
      end.to_xml
    end

    let(:invalid_content) do
      Tmt::XML::RDFXML.new(xmlns: {
        dcterms: :dcterms,
        rdf: :rdf,
      }, xml: {lang: :en}) do |xml|
        xml.add("dcterms:description") { "New description" }
        xml.add("dcterms:title") { "" }
      end.to_xml
    end

    def etag(model_object)
      Digest::MD5.hexdigest(model_object.reload.cache_key)
    end

    before do
      http_login(user)
      ready(project)
    end

#   [
#     ['application/xml', :xml],
#     ['application/rdf+xml', :rdf]
#   ].each do |content_type, format|
#     it "should update existing test case when If-Match is correct" do
#       get :show, service_provider_id: project.id, id: test_case.id, format: format
#       @request.env['If_Match'] = response.headers['ETag']
#       put :update, valid_content, {content_type: content_type, service_provider_id: project.id, id: test_case.id, format: format}
#       test_case.reload
#       test_case.description.should eq("New description")
#       test_case.name.should eq("New Title")
#       response.status.should eq(200)
#     end

#     it "should not update existing test case when If-Match header is present, buth there is some other problem or conflict with the update" do
#       get :show, service_provider_id: project.id, id: test_case.id, format: :xml
#       @request.env['If_Match'] = response.headers['ETag']
#       put :update, invalid_content, {content_type: content_type, service_provider_id: project.id, id: test_case.id, format: format}
#       response.status.should eq(409)
#     end

#     it "should not update existing test case when If-Match header is missing" do
#       put :update, valid_content, {content_type: content_type, service_provider_id: project.id, id: test_case.id, format: format}
#       response.status.should eq(400)
#     end

#     it "should not update existing test case when If-Match header don't match with current ETag" do
#       @request.env['If_Match'] = "incorrect"
#       put :update, valid_content, {content_type: content_type, service_provider_id: project.id, id: test_case.id, format: format}
#       response.status.should eq(412)
#     end
#   end
  end

  [
    ['application/rdf+xml', :rdf],
    ['application/xml', :xml]
  ].each do |content_type, format|
    describe "DELETE destroy for format #{format}" do
      let(:test_case) { create(:test_case_with_type_file, project: project) }

      before do
        ready(test_case, project)
      end

      it "doesn't authorize when user is not logged in" do
        test_case.deleted_at.should be_nil
        delete :destroy, {id: test_case.id, service_provider_id: project.id, format: format}
        response.status.should eq 401
        test_case.reload.deleted_at.should be_nil
      end

      it "doesn't authorize when user is not member of proejct" do
        http_login(create(:user))
        test_case.deleted_at.should be_nil
        delete :destroy, {id: test_case.id, service_provider_id: project.id, format: format}
        response.status.should eq 403
        test_case.reload.deleted_at.should be_nil
      end

      it "deletes test case object" do
        http_login(user)
        test_case.deleted_at.should be_nil
        delete :destroy, {id: test_case.id, service_provider_id: project.id, format: format}
        test_case.reload.deleted_at.should_not be_nil
      end

      it "return 204 status code when test case was properly deleted" do
        http_login(user)
        test_case.deleted_at.should be_nil
        delete :destroy, {id: test_case.id, service_provider_id: project.id, format: format}
        response.status.should eq 204
      end

      it "return 404 status code when test case doesn't exist" do
        http_login(user)
        delete :destroy, {id: 0, service_provider_id: project.id, format: format}
        response.status.should eq 404
      end

      it "return 404 status code when test case has got set deleted_at attribute" do
        http_login(user)
        test_case.update(deleted_at: Time.now)
        delete :destroy, {id: test_case.id, service_provider_id: project.id, format: format}
        response.status.should eq 404
      end
    end
  end
end
