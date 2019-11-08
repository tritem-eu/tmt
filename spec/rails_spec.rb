require 'spec_helper'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
load "#{Rails.root.to_s}/db/schema.rb"

describe Rails do
  it 'should include a correctly path to an application' do
    Rails.root.should_not eq('/')
    Rails.root.should_not eq('/*')
    Rails.root.should_not eq('/**/*')
    Rails.root.should_not be nil
    Rails.root.should_not eq('')
  end

  it 'should has "test" environment' do
    Rails.env.should eq('test')
  end
end
