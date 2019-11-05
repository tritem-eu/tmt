source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.0'

gem 'sqlite3', '~> 1.3.13'

gem 'rake', '~> 11.0'
gem 'rdoc', '4.2.0'
gem 'json', '1.7'
# sudo apt-get install libmysqlclient-dev
gem 'mysql2', '0.3.18'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'unparser', '0.2.4'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem 'appjs-rails'
gem 'jasmine', '~> 2.4.0'
gem 'base32', '0.3.2'
gem 'smart_csv', '0.0.9'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'remotipart', '~> 1.0'
gem 'prawn', '1.0.0'
gem 'rubyzip', '1.1.0'
gem 'font-awesome-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
#gem 'bootstrap-sass', '~> 3.0.0.0.rc'
gem 'rails-i18n'
#gem 'sunspot_rails', "2.0.0"
#gem 'sunspot_solr', "2.0.0"
gem 'kaminari', '0.16.3'

gem 'cancan', '~> 1.6.10'
gem 'ci_reporter', '1.9.2'
gem 'devise', '3.2.2'
gem 'devise_invitable', '1.3.3'
gem 'ptools', '1.3.3'

# Simple Rails app configuration
gem 'figaro', '0.7.0'
gem 'rolify', '3.3.0.rc4'
gem 'base_presenter', '~> 0.1.0'
gem 'rails_extras', '0.1.5', :require => [
  "rails_extras/helpers/tag",
  "rails_extras/rspec/support/common"
]
gem 'nokogiri', '~> 1.6.6.4'
group :assets do
  gem 'therubyracer', :platform=>:ruby
end

group :development do
  gem 'better_errors', '~> 2.1.0'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'zeus'
  gem 'mechanize', '2.7.2'
end

group :development, :test do
  gem 'rspec-rails', '3.4.0'#'2.14.2'
  #gem 'rspec-core', '2.14.8'
  gem 'rspec-collection_matchers'
  #gem 'rspec-legacy_formatters'
  gem 'selenium-webdriver'
  gem 'pry-rails'
  #gem 'reloader_gem', '0.2.2'
#  gem 'metric_fu', '4.12.0'
end

group :production do
  # the app server
	gem 'thin', '1.6.4'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'public_suffix', '~> 2.0'
  gem 'simplecov'
  gem 'simplecov-rcov'
end

gem 'pdf-inspector', :require => "pdf/inspector"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'
