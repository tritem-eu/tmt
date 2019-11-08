require 'spec_helper'

describe ::Tmt::Tasks::Script, type: :lib do
  describe "for export_version" do
    let(:user) { create(:user) }

    let(:script) do
      ::Tmt::Tasks::Script.new(verbose: 'false')
    end

    let(:project) do
      project = create(:project)
      project.add_member(user)
      project
    end

    before do
      ready(user, project)
      source = Rails.root.join('spec', 'files', 'test_cases')
      destination = Rails.root.join('tmp', 'script-peron-test')
      FileUtils.mkdir_p(destination)
      FileUtils.cp_r(source, destination)
    end

    it "should have correctly dir path" do
      $stdin.stub(:gets).and_return('1', '1') # select first user and project from lists
      script.dir.should eq(Rails.root.join('tmp', 'script-peron-test').to_s)
    end

=begin
    it "should upload files" do
      $stdin.stub(:gets).and_return('1', '1') # select first user and project from lists
      expect do
        script.upload_test_cases
      end.to change(::Tmt::TestCase, :count).by(5)
      ::Tmt::TestCase.exists?(name: 'TS-6565').should be 1
      ::Tmt::TestCaseVersion.exists?(comment: 'TS-6565').should be 1
    end
=end
    it "should not upload files when project isn't empty and user tells no" do
      create(:test_case, project: project)
      $stdin.stub(:gets).and_return('1', '1', 'no')
      expect do
        script.upload_test_cases
      end.to raise_error
      project.test_cases.should have(1).item
    end
=begin
    it "should upload files when project isn't empty and user tells yes" do
      create(:test_case, project: project)
      $stdin.stub(:gets).and_return('1', '1', 'yes')
      expect do
        script.upload_test_cases
      end.to change(::Tmt::TestCase, :count).by(5)
      ::Tmt::TestCase.exists?(name: 'TS-6565').should be 1
      ::Tmt::TestCaseVersion.exists?(comment: 'TS-6565').should be 1
    end
=end
    it "should upload catalog with files and create Set hierarchy" do
      $stdin.stub(:gets).and_return('1', '1') # select first user and project from lists
      script.upload_test_cases
      test_case = ::Tmt::TestCase.where(name: 'TS-6565').last

      set = ::Tmt::Set.where(name: 'Class_IC').last
      ::Tmt::TestCasesSets.exists?(test_case_id: test_case.id, set_id: set.id).should be 1
    end

  end
end
