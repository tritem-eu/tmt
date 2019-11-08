require 'spec_helper'

describe ::Tmt::Agent::Machine do

  let(:agent) { ::Tmt::Agent::Machine.new}
  let(:repository_path) { ::Tmt::Agent::Config.repository_path(:test) }
  let(:version) { create(:test_case_version) }

  it "should get status" do
    `cd #{repository_path} && touch example`
    agent.status.should include("?? example")
  end

  describe '#poke' do

    it "should save last revision into version record" do
      version.revision.should be_nil
      agent.poke
      revision = agent.last_revision
      version.reload
      version.revision.should eq(revision)
      version.revision.should_not be_blank
    end

    it "should not poke when destination don't exist" do
      version
      File.stub(:exist?) { false }
      expect do
        agent.poke
      end.to raise_error
    end

    it "should can save file into git and remove from store" do
      version
      File.exist?(version.anteroom_path).should be true
      File.exist?(version.repository_path).should be false
      agent.poke
      File.exist?(version.repository_path).should be true
      File.exist?(version.anteroom_path).should be false
    end

    it "should create new commit" do
      version
      last_revision = agent.last_revision
      agent.poke
      agent.last_revision.should_not eq(last_revision)
    end

    it "should rise error when file isn't added to track" do
      version
      last_revision = agent.last_revision
      agent.stub('status').and_return('', '', ' D')
      expect do
        agent.poke
      end.to raise_error(RuntimeError, "Agent can't add file '1' to track of repository")
    end

    it "should rise error when agent can't prepare workspace" do
      version
      last_revision = agent.last_revision
      agent.stub('status').and_return(' M some_file')
      expect do
        agent.poke
      end.to raise_error(RuntimeError, "Agent can't prepare workspace")
    end
  end

  describe ".working?" do
    it "should not work when process don't exist" do
      File.stub(:exist?) { false }
      ::Tmt::Agent::Machine.working?.should be false
    end

    it "should not work for process other than 'rails s' or 'thin'" do
      File.stub(:exist?) { true }
      File.stub(:read) { 'ruby' }
      ::Tmt::Agent::Machine.working?.should be false
    end

    it "should not work because something went wrong" do
      File.stub(:exist?) { raise 'Something went wrong' }
      ::Tmt::Agent::Machine.working?.should be false
    end

    it "should work" do
      File.stub(:exist?) { true }
      File.stub(:open) do
        file = 'file'
        def file.read
          'rails s'
        end
        file
      end
      ::Tmt::Agent::Machine.working?.should be true
    end

  end

  describe ".save_pid" do
    it "should save pid" do
      Tmt::Agent::Machine.stub(:killed_pid?) { true }
      Tmt::Agent::Machine.save_pid(Process.pid).should be true
      Tmt::Agent::Machine.read_pid.should eq(Process.pid)
    end

    it "should not save pid" do
      Tmt::Agent::Machine.stub(:killed_pid?) { false }
      Tmt::Agent::Machine.save_pid(Process.pid).should be false
    end
  end

  describe ".read_pid" do
    it "should return nil when process don't exist" do
      File.write(Rails.root.join('tmp', 'pids', 'agent-test.pid'), '')
      Tmt::Agent::Machine.read_pid.should be nil
    end

    it "should return pid of process of Agent" do
      File.stub(:exist?) { true }
      File.stub(:read) { Process.pid }
      Tmt::Agent::Machine.read_pid.should eq(Process.pid)
    end
  end

  describe ".show_content" do
    it "should show content of existing file" do
      version = create(:test_case_version)
      agent.poke
      version.reload.content.to_s.should_not eq('')
      ::Tmt::Agent::Machine.show_content(version.revision, version.test_case.id).should eq(version.content)
    end
  end

  describe ".killed_pid?" do
    it "should return true when neither agent works" do
      File.write(Rails.root.join('tmp', 'pids', 'agent-test.pid'), '')
      ::Tmt::Agent::Machine.killed_pid?.should be true
    end

    it "should return false when process is 'thin'" do
      pid = fork {}
      File.write(Rails.root.join('tmp', 'pids', 'agent-test.pid'), pid)
      File.stub(:open) do
        file = ''
        def file.read
          'thin'
        end
        file
      end
      ::Tmt::Agent::Machine.killed_pid?.should be false
    end
  end
end
