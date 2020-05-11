# encoding: utf-8

module Tmt

  def self.config
    unless defined?(@@config)
      @@config = case Rails.env.to_sym
      when :test
        test_config
      when :development
        development_config
      when :production
        production_config
      else
        raise "You did not properly defined environment."
      end
      @@config[:oslc] = {
        execution_adapter_type: {
          id: 'de.tritem.adapter',
          name: 'Tritem type',
          description: ''
        }
      }
      @@config[:expiration_date] = [3000, 1, 1]
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

  def self.test_config
    {
      mailer: {
        default_from: 'from@example.com',
        default_url_options: {
          host: 'localhost:3000'
        }
      },
      url_options: {
        host: 'localhost',
        port: 3000,
        protocol: 'http',
      }
    }
  end

  def self.development_config
    {
      mailer: {
        default_from: 'from@example.com',
        default_url_options: {
          host: 'localhost:3000'
        }
      },
      url_options: {
        host: 'localhost',
        port: 3000,
        protocol: 'http'
      }
    }
  end

  def self.production_config
    {
      url_options: {
        host: '10.11.0.155',
        port: '3000',
        protocol: 'https',
        script_name: '/tmt_production'
      },
      mailer: {
        default_from: 'from@example.com',
        default_url_options: {
          host: '10.11.0.155:3000',
          protocol: 'https',
          script_name: '/tmt_production'
        }
      }
    }
  end

  if 'sandbox' == ENV["TMT_CONFIG"]
    def self.production_config
      {
        url_options: {
          host: 'localhost',
          port: 3000,
          protocol: 'https',
        },
        db: "
          adapter: mysql2
          encoding: utf8
          database: tmt_test
          reconnect: true
          username: tmt_admin
          password: top-secret
          host: localhost
          port: 
        ",
        mailer: {
          default_from: 'from@example.com',
          default_url_options: {
            host: 'localhost:3000',
            protocol: 'https',
          },
        }
      }
    end
  end
end
