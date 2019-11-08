require 'spec_helper'

describe Tmt::Api::TestCaseVersionsController do
  extend CanCanHelper

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  let(:test_case) { create(:test_case_with_type_file) }
  let(:project) { test_case.project }

  let(:uploaded_file) { ::CommonHelper.uploaded_file('binary_file.zip')}
  let(:uploaded_file_seq) { ::CommonHelper.uploaded_file('short.seq')}

  before do
    ready(project)
  end

  describe "POST create" do

    it "creates a new TestCaseVersion" do
      http_login(user)

      expect do
        post :create, {project_id: project.id, test_case_id: test_case.id, datafile: [uploaded_file], format: :json}
      end.to change(Tmt::TestCaseVersion, :count).by(1)
    end

    it "creates a new TestCaseVersion when two files have diffrent contents" do
      http_login(user)

      create(:test_case_version, test_case: test_case, datafile: uploaded_file)
      expect do
        post :create, {project_id: project.id, test_case_id: test_case.id, datafile: [uploaded_file_seq], format: :json}
      end.to change(Tmt::TestCaseVersion, :count).by(1)
      uploaded_file_seq.rewind
      test_case.versions.last.content.should eq(uploaded_file_seq.read)
    end

    it "doesnt' create a new TestCaseVersion when two files have the same contents" do
      http_login(user)

      create(:test_case_version, test_case: test_case, datafile: uploaded_file)
      expect do
        post :create, {project_id: project.id, test_case_id: test_case.id, datafile: [uploaded_file], format: :json}
      end.to change(Tmt::TestCaseVersion, :count).by(0)
    end
  end

  describe "POST check-md5" do

    it "return is_another param with true value" do
      http_login(user)

      version = create(:test_case_version, test_case: test_case, datafile: uploaded_file)
      post :check_md5, {project_id: project.id, test_case_id: test_case.id, md5: "example", format: :json}
      response.body.should eq({is_another: true, is_error: false}.to_json)
    end

    it "return is_another param with false value" do
      http_login(user)

      version = create(:test_case_version, test_case: test_case, datafile: uploaded_file)
      uploaded_file.rewind
      post :check_md5, {project_id: project.id, test_case_id: test_case.id, md5: ::Digest::MD5.hexdigest(uploaded_file.read), format: :json}
      response.body.should eq({is_another: false, is_error: false}.to_json)
    end

    it "return is_error param with true value because don't exist a test case" do
      http_login(user)
      post :check_md5, {project_id: project.id, test_case_id: 0, md5: 'example', format: :json}
      response.body.should eq({is_error: true}.to_json)
    end
  end
end
