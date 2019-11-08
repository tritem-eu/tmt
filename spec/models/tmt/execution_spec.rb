require 'spec_helper'

describe Tmt::Execution do

  let(:execution) { create(:execution) }

  let(:datafiles) { ["<html><body><h1>Error</h></body></html>"] }

  before do
   clean_execution_repository
   ready(execution)
  end

  describe 'for validation' do
    it "should create factory" do
      expect do
        create(:execution)
      end.to_not raise_error
    end

    it "should validate for result from 'none' to 'executing'" do
      execution.status.should eq :none
      execution.update(status: :executing).should be true
      execution.status.should eq :executing
    end

    it "should validate for result from 'executing' to 'none'" do
      execution.update(status: :executing)
      execution.status.should eq :executing
      execution.update(status: :none).should be true
      execution.status.should eq :none
    end

  end

  [:none, :executing, :failed, :error, :passed].product([
    'no-defined', :none, :executing, :failed, :error, :passed
  ]).each do |status_from, status_to|
    [nil, ''].product([nil, 'comment']).each do |datafiles, comment|
      #next unless status_from == 'no-defined' and status_to == 'executing'
      #next if not comment.nil?
      #next if not datafiles.nil?
     it "change status from '#{status_from}' to '#{status_to}' and comment exist: #{comment.nil?} and datafile exist: #{datafiles.nil?}" do
       datafiles = [upload_file('test_case_version')] unless datafiles.nil?
       execution.status = status_from
       execution.save(validate: false)
       result = false
       if [:none, :executing].include?(status_from)
         if [:none, :executing, :failed, :error, :passed].include?(status_to)
           case status_to
           when :none, :executing
             result = true if datafiles.nil?
           when :failed, :error, :passed
             result = true if not comment.nil? or not datafiles.nil?
           else

           end
         end
       end
       execution.update(status: status_to, comment: comment, datafiles: datafiles).should eq result
     end
    end
  end

  it "should attach file after save" do
    uuid = SecureRandom.uuid
    SecureRandom.stub(:uuid) { uuid }
    file = upload_file('test_case_version')
    execution.update(status: :failed, comment: 'comment', datafiles: [file])
    execution.attached_files.should have(1).items
    subject = execution.attached_files[0]
    subject.should include(original_filename: "test_case_version")
    Base32.encode('test_case_version').should include('ORSXG5C7MNQXGZK7OZSXE43JN5XA')
    subject.should include(server_filename: "#{uuid}_ORSXG5C7MNQXGZK7OZSXE43JN5XA.gz")

    subject.should include(uuid: uuid)
    subject.should have_key(:compressed_file)
    subject[:compressed_file].decompress.should include file.read
    subject.should have_key(:server_path)
  end

  it "should compress file after upload itself" do
    uuid = SecureRandom.uuid
    SecureRandom.stub(:uuid) { uuid }
    file = upload_file('test_case_version')
    execution.update(status: :failed, comment: 'comment', datafiles: [file])
    gz_file = execution.attached_files.first[:compressed_file]
    file.rewind
    gz_file.read.size.should be < file.read.size

    file.rewind
    ::Tmt::Lib::Gzip.decompress_from(gz_file.path).should eq file.read
  end

  it "should find path for uuid" do
    uuid = SecureRandom.uuid
    SecureRandom.stub(:uuid) { uuid }
    execution.update(status: :failed, comment: 'comment', datafiles: [upload_file('test_case_version')])
    Base32.encode('test_case_version').should include('ORSXG5C7MNQXGZK7OZSXE43JN5XA')
    execution.find_file_path(uuid).should match /.*test.*#{uuid}_ORSXG5C7MNQXGZK7OZSXE43JN5XA.gz/
  end

  it "update_for_user" do
    execution = create(:execution_for_failed)
    execution.status.should eq :failed
    execution.progress.should eq 0

    execution.update_for_user(progress: 13, status: 'passed')
    execution.reload.status.should eq 'failed'
    execution.reload.progress.should eq 0

    execution.update_for_user(progress: 13)
    execution.reload.progress.should eq 13
  end

  [1, 2, 3].each do |ddd|
    it "" do
      1.should eq 1
    end
  end

end
