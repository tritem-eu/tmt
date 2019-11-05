module Tmt
  module Agent
    class Config

      def self.unblocked=(value)
        @@unblocked = value# if [true, false].inclue?(value)
      end

      def self.unblocked?
        @@unblocked = true unless defined?(@@unblocked)
        @@unblocked
      end

      def self.repository_path(environment)
        check_rails
        {
          production: "#{Rails.root.join('private', 'versions-repository-production')}",
          development: "#{Rails.root.join('private', 'versions-repository-development')}",
          test: "#{Rails.root.join('private', 'versions-repository-test')}"
        }[environment]
      end

      def self.anteroom_path(environment)
        check_rails
        {
          production: "#{Rails.root.join('private', 'versions-anteroom-production')}",
          development: "#{Rails.root.join('private', 'versions-anteroom-development')}",
          test: "#{Rails.root.join('private', 'versions-anteroom-test')}"
        }[environment]
      end

      # Return actural environment
      def self.environment
        Rails.env.to_sym
      end

      def self.verbose=(value)
        @@verbose = value
      end

      def self.verbose
        @@verbose
      rescue
        true
      end

      def self.agent_email
        "agent@example.com"
      end

      # Create directories local store
      def self.create_anteroom(environment)
        return unless [:test, :development, :production].include?(environment)
        create_new_path(anteroom_path environment)
      end

      # Create initialize local git
      def self.create_repository(environment)
        return unless [:test, :development, :production].include?(environment)
        path = repository_path(environment)
        create_new_path(path)
        unless git_exist?(path)
          result = `cd #{path} && git init && git config user.name "Agent" && git config user.email "#{agent_email}" && touch .keep && git add -A && git commit -m "Initialized repository"`
          puts result if verbose == true
        end
      end

      # Remove directory of git repository path which is defined in method repository_path
      def self.remove_repository(environment)
        path = repository_path(environment)
        unless [:test, :development].include?(environment)
          return p "For #{environment} environment you must manually remove directory '#{path}'"
        else
          unless path.nil? or path == "/" or path == "/**/*" or path == "/*"
            FileUtils.rm_r(path, force: true)
            result = "Removed directory: #{path}"
            puts result if verbose == true
          end
        end
      end

      # Remove directory of anteroom path which is defined in method anteroom_path
      def self.remove_anteroom(environment)
        path = anteroom_path(environment)
        unless [:test, :development].include?(environment)
          return p "For #{environment} environment you must manually remove directory '#{path}'"
        else
          unless path.nil? or path == "/" or path == "/**/*" or path == "/*"
            FileUtils.rm_r(path, force: true)
            result = "Removed directory: #{path}\n"
            puts result if verbose == true
          end
        end
      end

      private

      def self.check_rails
        raise "Don't initialized class Rails" if defined?(Rails).nil?
      end

      def self.create_new_path(path)
       unless Dir.exist?(path)
          FileUtils.mkpath path
          result = "Created directory: #{path}"
          puts result if verbose == true
        end
      end

      # Return true if in path exist repository git
      def self.git_exist?(path)
        Dir.exist?(File.join(path, ".git"))
      end
    end
  end
end
