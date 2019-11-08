require 'spec_helper'

describe Tmt::Execution do
  let(:test_run) { create(:test_run) }

  describe "For test case with type has_file equal true" do
    let(:author) { create(:user) }
    let(:type) { create(:test_case_type, has_file: true) }
    let(:test_case) { create(:test_case, type: type) }

    let(:upload_file) do
      upload_file('test_case_version', 'text/plain')
    end

    let(:valid_attributes) do
      {
        author_id: author.id,
        test_case_id: test_case.id,
        comment: "Example comment",
        datafile: upload_file
      }
    end

    let(:new_version) { Tmt::TestCaseVersion.new(valid_attributes) }

    let(:version) do
      version = new_version
      version.save
      version
    end

    it "should duplicate records" do
      test_run.executions.create(version_id: 1).should be_a Tmt::Execution
      test_run.executions.new(version_id: 1).should be_valid
    end

    it "should get properly status" do
      create(:test_run).status_name.should eq(:new)
    end
  end
end
