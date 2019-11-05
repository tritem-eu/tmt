# encoding: utf-8

module Tmt
  module Agent
    class Machine
      def initialize
        @environment = Rails.env.to_sym
        @repository_path = ::Tmt::Agent::Config.repository_path(@environment)
        @anteroom_path = ::Tmt::Agent::Config.anteroom_path(@environment)
        self.class.create_directories
      end

      def self.create_directories
        environment = Rails.env.to_sym
        repository_path = ::Tmt::Agent::Config.repository_path(environment)
        FileUtils.mkdir_p(repository_path)
        anteroom_path = ::Tmt::Agent::Config.anteroom_path(environment)
        FileUtils.mkdir_p(anteroom_path)
      end

      def poke
        versions = Tmt::TestCaseVersion.where(revision: nil)
        versions.each do |version|
          repository_file_name = version.test_case.id.to_s
          prepare_workspace
          copy_file(version.id.to_s, repository_file_name)
          add_file_to_track(repository_file_name)
          if make_commit?(version.id)
            version.update(revision: last_revision)
            delete_anteroom_file(version.id.to_s)
          end
        end
      end

      def self.show_content(revision, test_case_id)
        repository_path = ::Tmt::Agent::Config.repository_path(Rails.env.to_sym)
        tmp_path = "/tmp/tmt"
        filepath = "#{tmp_path}/version-repository-#{Process.pid}-#{revision}-#{test_case_id}"
        `mkdir -p #{tmp_path}`
        `cd #{repository_path} && git show #{revision}:#{test_case_id} > #{filepath}`
        content = ::File.open(filepath, 'rb').read
        ::FileUtils.rm(filepath)
        content
      end

      def last_revision
        `cd #{@repository_path} && git log --pretty=format:'%H' -n 1`
      end

      def status
        `cd #{@repository_path} && git status -s`
      end

      def self.filepath
        Rails.root.join('tmp', 'pids', "agent-#{Rails.env}.pid").to_s
      end

      def self.read_pid
        pid = nil
        if File.exist?(filepath)
          pid = File.read(filepath).to_i
          pid = nil if pid == 0
        end
        pid
      end

      def self.save_pid(pid = nil)
        if killed_pid?
          FileUtils.mkdir_p(Rails.root.join('tmp', 'pids'))
          File.write(filepath, pid)
          true
        else
          false
        end
      end

      def self.working?
        pid = read_pid
        cmdline = File.open("/proc/#{pid}/cmdline", "rb").read
        if cmdline =~ /(rails.s|thin)/
          true
        else
          false
        end
      rescue
        false
      end

      def self.killed_pid?
        pid = read_pid
        return true unless File.exist?("/proc/#{pid}/cmdline")
        cmdline = File.open("/proc/#{pid}/cmdline", "rb").read
        if cmdline =~ /(rails.s|thin)/
          begin
            Process.kill 'HUP', pid
          rescue SignalException => e

          end
          `ps aux | grep -v grep | grep #{pid}` == ''
        else
          FileUtils.mkdir_p(Rails.root.join('tmp', 'pids'))
          File.write(filepath, '')
          return true
        end
      end

      private

      def prepare_workspace
        `cd #{@repository_path} && git reset`
        `cd #{@repository_path} && git clean -f`
        `cd #{@repository_path} && git stash`
        `cd #{@repository_path} && git stash drop` unless status == ""
        unless status == ""
          raise "Agent can't prepare workspace"
        end
      end

      def copy_file(source_file_name, destination_file_name)
        source = File.join(@anteroom_path, source_file_name)
        destination = File.join(@repository_path, destination_file_name)

        FileUtils.cp(source, destination)

        if not File.exist?(destination) or not FileUtils.compare_file(source, destination)
          raise "Agent can't copy file into repository (#{source} -> #{destination})"
        end
      end

      def delete_anteroom_file(file_name)
        filepath = File.join(@anteroom_path, file_name)
        FileUtils.rm(filepath) if File.file?(filepath)
      end

      # Return false if file isn't add to track
      def add_file_to_track(file_name)
        `cd #{@repository_path} && git add -A`
        unless ["A  #{file_name}\n", "M  #{file_name}\n", ""].include?(status)
          raise "Agent can't add file '#{file_name}' to track of repository"
        end

      end

      # Return false if don't added commit
      def make_commit?(message)
        old_revision = last_revision
        `cd #{@repository_path} && git commit -m "#{message}" --allow-empty`
        (last_revision == old_revision ? false : true)
      end

    end
  end
end
