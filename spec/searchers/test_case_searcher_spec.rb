require 'spec_helper'

describe Tmt::TestCaseSearcher do

  let(:project) { create(:project) }

  let(:test_cases_example) {
    [
      'example',
      'ex3mple',
      'Deska ex mple',
    ].map{ |name| create(:test_case, name: name, project: project) }
  }

  let(:test_case_foreign) {
    create(:test_case, name: 'foreign', project: project)
  }

  let(:user) {
    user = create(:user)
    project.add_member(user)
    user
  }

  it "select all recores with name 'ex?mple' where on position 3 is any character" do
    test_cases_example
    test_case_foreign
    Tmt::TestCaseSearcher.new({
      project: project,
      user: user,
      params: {
        'search' => 'ex?mple',
        'action' => 'index'
      }
    }).with_filter.should match_array(test_cases_example)

  end

  it "select all recores with name 'ex%ple' with group of any characters on position 3" do
    test_cases_example
    test_case_foreign
    Tmt::TestCaseSearcher.new({
      project: project,
      user: user,
      params: {
        'search' => 'ex%ple',
        'action' => 'index'
      }
    }).with_filter.should match_array(test_cases_example)

  end

end
