module Tmt
  module Tasks
    class Script
      attr_reader :dir, :project, :user

      def initialize(options)
        @verbose = true
        @verbose = false if options[:verbose] == 'false'
        @environment = Rails.env.to_sym
        @dir = Rails.root.join('tmp', "script-peron-#{@environment}").to_s
        @project = nil
        @user = nil
      end

      def upload_test_cases
        ::Tmt::Agent::Machine.killed_pid?
        sleep 1
        if ::Tmt::Agent::Machine.killed_pid?
          FileUtils.mkdir_p(@dir)
          list = Dir["#{@dir}/**/*"]
          if list.empty?
            raise 'The directory #{@dir} is empty'
          else
            all_files_are_ready?(list)
            select_user
            select_project
            create_test_cases_with_versions(list)
          end
        end
      end

      private

      def all_files_are_ready?(list)
        winner = [nil, -1]
        list.each do |filepath|
          if File.file?(filepath) and winner[1] < File.size(filepath)
            winner = [filepath, File.size(filepath)]
          end
        end
        file_size = ::Tmt::Cfg.first.file_size
        if winner[1] > file_size*(2**20)
          raise "The size of file #{winner[0]} is #{winner[1].to_f/(2**20)} MB and it is larger than #{file_size} MB. Please change this option in admin panel"
        end
      end

      def create_test_cases_with_versions(list)
        test_case_type = ::Tmt::TestCaseType.where(has_file: true, extension: 'seq').first
        return show('Application has not defined TestCaseType model') unless test_case_type

        begin
          list.each_with_index do |dir_with_filename, index|
            if File.file?(dir_with_filename)
              filename = dir_with_filename.scan(/([^\\\/]*)$/).flatten.first
              show_inline("\r   #{'%.2f' % ((index + 0.0) / list.length * 100)}% - #{filename}")

              test_case = ::Tmt::TestCase.where({name: filename.gsub(/\.[^\.]*$/, ''), project_id: @project.id, type_id: test_case_type.id, creator: @user}).first_or_create
              uploaded_file = ActionDispatch::Http::UploadedFile.new({
                filename: filename,
                content_type: test_case_type,
                tempfile: File.new(dir_with_filename)
              })
              version = ::Tmt::TestCaseVersion.create(test_case_id: test_case.id, comment: filename.gsub(/\.[^\.]*$/, ''), author: @user, datafile: uploaded_file)
              set = generate_sets_with(dir_with_filename, @project.id)
              set.test_cases_sets.create(test_case_id: test_case.id) if set
            end
          end
          show_inline("\r 100% - properly Finished properly")
        rescue => e
          show("\r #{e.message}")
        end
      end

      def generate_sets_with(text, project_id)
        sets = text.gsub(@dir, '').split('/')[0...-1]
        set = nil
        sets.each do |name|
          unless set
            set = ::Tmt::Set.where(name: name, parent_id: nil, project_id: project_id).first_or_create
          else
            set = ::Tmt::Set.where(name: name, parent_id: set.id, project_id: project_id).first_or_create
          end
        end
        set
      end

      def select_project
        projects = ::Tmt::Project.all
        raise "\nThe list of projects is empty. Please create the project" if projects.empty?
        show 'Select project id where we must add the test cases:'
        projects.each do |project|
          show "  #{project.id}. #{project.name} (TestCases: #{project.test_cases.size}, Is member: #{@user.member_for_project(project).is_active})"
        end
        show_inline "project id: "
        id = $stdin.gets.strip.to_i
        @project = projects.where(id: id).first
        raise "Your id '#{id}' is not properly value" unless @project
        if @project.test_cases.size > 0
          show "The Project '#{@project.name}' is not empty. Do you want to overwrite the existing project (y)es?"
          unless ['yes', 'y'].include?($stdin.gets.strip)
            raise "You do not overwrite the project #{@project.name}."
          end
        end
      end

      def select_user
        users = User.all
        raise "\nThe list of users is empty. Please create the user" if users.empty?

        show 'Select user id who will be creator of project and test cases:'
        users.each do |user|
          show "  #{user.id}. #{user.name} #{user.email}"
        end
        show "user id: "

        id = $stdin.gets.strip.to_i

        @user = users.where(id: id).first
        raise "Your id '#{id}' is not properly value" unless @user
      end

      def show(text)
        if @verbose
          text.to_s.split(/.{1, 80}/).each do |subtext|
            puts subtext
          end
        end
      end

      def show_cut(text)
        puts "#{text}#{' '*80}"[0..80] if @verbose
      end

      def show_inline(text)
        print "#{text}#{' '*80}"[0..80] if @verbose
      end
    end
  end
end
