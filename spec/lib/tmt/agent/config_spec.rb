require 'spec_helper'

describe ::Tmt::Agent::Config do
  let(:config) { ::Tmt::Agent::Config }

  it "can change value of verbose" do
    config.verbose = false
    config.verbose.should be false
    config.verbose = true
    config.verbose.should be true
  end

  it 'should have setting unblocked' do
    config.unblocked?.should eq(true)
    config.unblocked=(false)
    config.unblocked?.should eq(false)
  end

  it "should has email of agent" do
    config.agent_email.should eq("agent@example.com")
  end

  it "should properly get actual environment of application" do
    config.environment.should eq(:test)
  end

  it "should remove anteroom path directories for test environment" do
    anteroom_path = config.anteroom_path(:test)
    config.remove_anteroom(:test)
    Dir.exist?(anteroom_path).should be false
  end

  it "should not remove anteroom path directories for dummy environment" do
    config.remove_anteroom(:dummy).should eq(%Q{For dummy environment you must manually remove directory ''})
  end

  it "should remove git path for test environment" do
    repository_path = config.repository_path(:test)
    config.remove_repository(:test)
    Dir.exist?(repository_path).should be false
  end

  it "should not remove git path for dummy environment" do
    config.remove_repository(:dummy).should eq(%Q{For dummy environment you must manually remove directory ''})
  end

  it "should create git path for test environment" do
    repository_path = config.repository_path(:test)
    config.create_repository(:test)
    Dir.exist?(repository_path).should be true
  end

  it "should create anteroom path for test environment" do
    anteroom_path = config.anteroom_path(:test)
    config.create_anteroom(:test)
    Dir.exist?(anteroom_path).should be true
  end
end
