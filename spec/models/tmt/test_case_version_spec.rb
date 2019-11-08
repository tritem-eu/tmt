require 'spec_helper'

describe Tmt::TestCaseVersion do
  let(:author) { create(:user) }

  it "has_many versions" do
    version = create(:test_case_version)
    execution = create(:execution, version: version)
    foreign_execution = create(:execution, version: create(:test_case_version))
    version.executions.should match_array([execution])
  end

  describe "For test case with type has_file equal true" do
    let(:author) { create(:user) }
    let(:type) { create(:test_case_type, has_file: true, extension: nil) }
    let(:test_case) { create(:test_case, type: type) }

    let(:upload_file) do
      CommonHelper.uploaded_file('test_case_version', content_type: 'text/plain')
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

    it "should properly valid attributes" do
      new_version.should be_valid
    end

    it "shouldn't be a valid when comment is empty" do
      new_version.comment = ""
      new_version.should_not be_valid
    end

    it "shouldn't be a valid when author is empty" do
      new_version.author = nil
      new_version.should_not be_valid
    end

    it "shouldn't be a valid when test case is empty" do
      new_version.test_case = nil
      expect do
        new_version.save
      end.to raise_error
    end

    it "shouldn't be a valid when datafile is empty" do
      new_version.datafile = nil
      new_version.should_not be_valid
      new_version.errors[:datafile].should include("don't added file")
    end

    it "shouldn't be a valid when datafile is empty and exist another one version" do
      version = create(:test_case_version_with_revision, test_case: test_case)
      version.id.should_not be_nil
      new_version.datafile = nil
      expect do
        new_version.save
      end.to_not raise_error
    end

    it "shouldn't create new version if some record has the same content" do
      version = create(:test_case_version, test_case: test_case)
      expect do
        new_version = create(:test_case_version, test_case: test_case.reload, datafile: ::CommonHelper.uploaded_file('test_case_version'))
      end.to raise_error(ActiveRecord::RecordInvalid, /has the same content as last uploaded file/)
    end

    describe 'validation at test_case_type relation' do
      it "shouldn't validate when file has got incorrectly extension" do
        type = create(:test_case_type, extension: 'txt', has_file: true)
        test_case = create(:test_case, type: type)
        expect do
          create(:test_case_version, test_case: test_case, datafile: ::CommonHelper.uploaded_file('main_sequence.seq'))
        end.to raise_error(ActiveRecord::RecordInvalid, /should has got 'txt' extension/)
      end

      it "should validate when file has got correctly extension" do
        type = create(:test_case_type, extension: 'seq', has_file: true)
        test_case = create(:test_case, type: type)
        expect do
          create(:test_case_version, test_case: test_case, datafile: ::CommonHelper.uploaded_file('main_sequence.seq'))
        end.to_not raise_error
      end

      it "should validate when test case has got type for all extensions of file" do
        type = create(:test_case_type, extension: '', has_file: true)
        test_case = create(:test_case, type: type)
        expect do
          create(:test_case_version, test_case: test_case, datafile: ::CommonHelper.uploaded_file('main_sequence.seq'))
        end.to_not raise_error
      end
    end

    describe "#content" do
      it "should get conten of file from git" do
        version.stub(:revision).and_return("git-hash")
        ::Tmt::Agent::Machine.stub(:show_content).and_return(upload_file.read)
        version.content.should eq(upload_file.read)
      end

      it "should have original content when file is stored in anteroom" do
        uploaded_file = CommonHelper.uploaded_file('binary_file.zip')
        version = create(:test_case_version, datafile: uploaded_file, test_case: test_case)
        uploaded_file.rewind
        content = uploaded_file.read
        content.should_not be_empty
        version.content.should eq(content)
      end

      it "should have original content when file is stored in repository" do
        uploaded_file = CommonHelper.uploaded_file('binary_file.zip')
        version = create(:test_case_version, datafile: uploaded_file, test_case: test_case)
        uploaded_file.rewind
        content = uploaded_file.read
        content.should_not be_empty
        ::Tmt::Agent::Machine.new.poke
        sleep 1
        version.reload.content.should eq(content)
      end
    end

    it "should set file name when datafile exists" do
      new_version.file_name.should be_nil
      new_version.save
      new_version.file_name.should eq("test_case_version")
    end

    it "shouldn't valid file larger than 2 MB" do
      upload_file.stub(:size) { 3 * 2**20}
      new_version.should_not be_valid
    end

    it "should valid file less than 2 MB" do
      upload_file.stub(:size) { 2 * 2**20}
      new_version.should be_valid
    end
=begin
    it "should save size of file" do
      version.file_size.should eq(2223)
    end
=end
    it "should know that it is a file" do
      version.test_case.stub(:type).and_return(create(:test_case_type, has_file: true))
      version.file?.should be true
    end
  end

  describe "For test case with type has_file equal false" do
    let(:type) { create(:test_case_type, has_file: false, extension: nil) }
    let(:test_case) { create(:test_case, type: type) }
    let(:content) { "Example script"}
    let(:valid_attributes) do
      {
        author_id: author.id,
        test_case_id: test_case.id,
        comment: "Example comment",
        datafile: content
      }
    end

    let(:new_version) { Tmt::TestCaseVersion.new(valid_attributes) }

    let(:version) do
      version = new_version
      version.save
      version
    end

    it "should properly valid attributes" do
      new_version.should be_valid
    end

    it "shouldn't be a valid when comment is empty" do
      new_version.comment = ""
      new_version.should_not be_valid
    end

    it "shouldn't be a valid when author is empty" do
      new_version.author = nil
      new_version.should_not be_valid
    end

    it "shouldn't be a valid when test case is empty" do
      new_version.test_case = nil
      expect do
      new_version.save
      end.to raise_error
    end

    it "should not be a valid when datafile is empty" do
      new_version.datafile = nil
      new_version.should_not be_valid
    end

    it "should set file name when datafile exists" do
      new_version.file_name.should be_nil
      new_version.save
      new_version.file_name.should eq("script-#{new_version.comment}")
    end

    it "should save size of file" do
      version.file_size.should eq(14)
    end

    it "should get conten of file from git" do
      version.stub(:revision).and_return("git-hash")
      ::Tmt::Agent::Machine.stub(:show_content).and_return(content)
      version.content.should eq(content)
    end

    it "should not change revision when it is filled in" do
      version.update(revision: 'example-revision')
      version.reload.revision.should eq('example-revision')
      expect do
        version.update!(revision: 'example-revision')
      end.to raise_error(ActiveRecord::RecordInvalid, /Revision was saved/)
    end


    it "should know that it is a script" do
      version.file?.should be false
    end
  end

  describe "#md5" do
    let(:uploaded_file) do
      CommonHelper.uploaded_file('test_case_version', content_type: 'text/plain')
    end

    it "for test case for file" do
      version = create(:test_case_version, {
        test_case: create(:test_case_with_type_file),
        datafile: uploaded_file
      })
      uploaded_file.rewind
      version.md5.should eq(::Digest::MD5.hexdigest(uploaded_file.read))
    end

    it "for test case for script" do
      version = create(:test_case_version, {
        test_case: create(:test_case),
        datafile: 'Example',
        comment: "Example comment"
      })
      version.md5.should eq(::Digest::MD5.hexdigest('Example'))
    end

  end

  describe "#after_create" do
    it 'should set current version id in test case record' do
      test_case = create(:test_case)
      test_case.current_version_id.should be_nil
      version = create(:test_case_version, {
        test_case: test_case,
        datafile: 'Example',
        comment: "Example comment"
      })
      test_case.current_version_id.should eq(version.id)
    end
  end
end
