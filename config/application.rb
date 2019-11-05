require File.expand_path('../boot', __FILE__)
require File.expand_path('../../config', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(:default, Rails.env)

module Tmt
  module Lib

  end
end

module Tmt

  class Application < Rails::Application
    # don't generate RSpec tests for views and helpers
    config.generators do |g|

      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'

      g.view_specs false
      g.helper_specs false
    end
    config.label_text = lambda { |label, required| "#{label}" }
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      unless html_tag =~ /^<label/
        %Q{<span class='control-group has-error'>#{html_tag}<label for="#{instance.send(:tag_id)}" class="help-inline text-danger">#{instance.error_message.first}</label></span>}.html_safe
      else
        "#{html_tag}".html_safe
      end
    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    #config.autoload_paths += Dir["#{config.root}/app/oslc/"]

    config.assets.paths << "#{Rails}/app/assets/fonts"
    #config.active_record.timestamped_migrations = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # http://www.redguava.com.au/2010/12/rails-basics-handling-user-timezones-in-rails/
    config.time_zone = 'Warsaw'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales','models', '*.yml').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales','controllers', '*.yml').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales','helpers', '*.yml').to_s]

    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    config.before_initialize do
      require 'rake'
      Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
      Tmt::Application.load_tasks # providing your application name is 'sample'
    # -> do
    #   if [:development, :test].include?(Rails.env.to_sym)
    #     if `ps aux | grep -v grep | grep #{Rails.root}/solr/data/#{Rails.env}`.lines.size == 0
    #       Rake::Task['sunspot:solr:start'].invoke
    #     end
    #   end
    # end.call
    end

    # This change breaks remote forms that need to work also without JavaScript, so if you need such behavior, you can either set it to true or explicitly pass authenticity_token: true in form options.
    config.action_view.embed_authenticity_token_in_remote_forms = true
  end
end

require 'lib'
require Rails.root.join('app', 'oslc', 'oslc')
