# encoding: utf-8

module Tmt
  def self.config
    unless defined?(@@config)
      @@config = {}
      @@config[:mailer] = Rails.application.config_for(:mailer).to_h.deep_symbolize_keys
      @@config[:url_options] = Rails.application.config_for(:url_options).to_h.deep_symbolize_keys
      @@config[:smtp_settings] = Rails.application.config_for(:smtp_settings).to_h.deep_symbolize_keys
      @@config[:oslc] = {
        execution_adapter_type: {
          id: 'de.tritem.adapter',
          name: 'Tritem type',
          description: ''
        }
      }
      @@config[:expiration_date] = [3000, 1, 1]
    end

    def @@config.SMTP_SETTINGS
      @@config[:smtp_settings]
    end

    def @@config.MAILER_DEFAULT_FROM
      @@config[:mailer][:default_options][:from]
    end

    def @@config.MAILER_DEFAULT_OPTIONS
      @@config[:mailer][:default_options]
    end

    def @@config.MAILER_DEFAULT_URL_OPTIONS
      @@config[:mailer][:default_url_options]
    end

    def @@config.value(*args)
      result = @@config
      args.each do |arg|
        result = result[arg]
      end
      result
    rescue
      nil
    end
    @@config
  end
end