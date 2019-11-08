require 'spec_helper'

describe Oslc::User::Query do
  let(:peter) do
    create(:user, name: "Peter")
  end

  let(:john) do
    create(:user, name: "John")
  end

  def query(syntax)
    Oslc::User::Query.new.where(syntax)
  end

  before do
    ready(john, peter)
  end

  it "should return executions when query syntax is empty" do
    query(nil).should match_array [
      john,
      peter
    ]
  end

  it "should return users with appropriate 'foaf:name' property" do
    query("foaf:name=\"#{john.name}\"").should match_array [john]
  end

  it "should return users with appropriate 'foaf:email' property" do
    query("foaf:mbox=\"mailto:#{peter.email}\"").should match_array [peter]
  end

end
