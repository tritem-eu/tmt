# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
Time.zone = 'UTC'
require 'rspec/rails'
require 'email_spec'
require 'simplecov'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'support/can_can.rb'
require 'rails_extras/rspec/support/wait_for_ajax'

class DummySpecController
  include Rails.application.routes.url_helpers

  attr_accessor :request

  def initialize(options={})
    Rails.application.routes.default_url_options[:host] = Tmt.config[:url_options][:host]
    Rails.application.routes.default_url_options[:port] =  Tmt.config[:url_options][:port]
    #Rails.application.routes.default_url_options[:script_name] =  Tmt.config[:url_options][:script_name]
    self.request = {}
    @format = options[:format]
    @request_accept = options[:request_accept]
    @current_user = options[:current_user]

    def request.url
      @request_url
    end
  end

  def set_request_url(url=nil)
    @request_url = url
  end

  def current_user(current_user=nil)
    @current_user
  end

  def request_format
    @format || :html
  end
end

def server_url(sub_url='')
  "http://localhost:3000#{sub_url}"
end

if( ENV["COVERAGE"] )
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
       SimpleCov::Formatter::HTMLFormatter.new.format(result)
       SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start do
    add_filter 'spec'
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include CommonHelper
  #config.include CanCanHelper, type: :controller
  config.include RailsExtras::RSpec::Support::Common
  config.include RailsExtras::RSpec::Support::WaitForAjax, type: :feature
  config.include FactoryGirl::Syntax::Methods
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  # config.filter_run js: true
  # config.filter_run_excluding js: true
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.render_views

  #config.formatter = RailsExtras::RSpec::Formatters::NumericProgress

  # Use the fail_fast option to tell RSpec to abort the run on first failure.
  # config.fail_fast = true

  config.before(:suite) do
    load "#{Rails.root}/db/seeds.rb"
  end

  config.before(:each) do |example|
    Rails.application.routes.default_url_options = {}

    if example.metadata[:js] == true
      DatabaseCleaner.strategy = :truncation
      load "#{Rails.root}/db/seeds.rb"
    end
    Tmt::Cfg.first.update(max_name_length: 40)

    DatabaseCleaner.start
    Time.zone = 'UTC'
    ::Tmt::Agent::Config.verbose = false
    ::Tmt::Agent::Config.remove_anteroom(:test)
    ::Tmt::Agent::Config.remove_repository(:test)
    ::Tmt::Agent::Config.create_anteroom(:test)
    ::Tmt::Agent::Config.create_repository(:test)
    clean_execution_repository
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do |example|
    if example.nil?
      print "\n#{'*'*80} \n  You can also run:\n\n  rspec spec --tag @js \n\n  rake jasmine \n#{'*'*80}"
    end
  end
end

Capybara.register_driver :selenium do |app|
  ENV['HTTP_PROXY'] = ENV['http_proxy'] = nil
  profile = Selenium::WebDriver::Firefox::Profile.new

  # Turn off the accessibility redirect popup
  profile["network.http.prompt-temp-redirect"] = false
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile, :proxy => nil)
end
#Capybara.register_driver :chrome do |app|
#  ENV['HTTP_PROXY'] = ENV['http_proxy'] = nil
#  Capybara::Selenium::Driver.new(app, :browser => :chrome, :proxy => nil)
#end
#Capybara.javascript_driver = :chrome
