module Tmt
  class Execution < ActiveRecord::Base
    STATUS_EXECUTING = :executing
    STATUS_NONE = :none
    STATUS_PASSED = :passed
    STATUS_FAILED = :failed
    STATUS_ERROR = :error

    before_validation do
      self.status ||= :none
      self.progress ||= 0
    end

    after_save :save_attached_file
    after_update :notify_execution_status

    belongs_to :version, class_name: "Tmt::TestCaseVersion"

    belongs_to :test_run, class_name: "Tmt::TestRun"
    has_one :campaign, through: :test_run
    has_one :project, through: :campaign
    has_one :test_case, through: :version

    #validates :version_id, uniqueness: {scope: :test_run_id, message: "The version should be unique"}
    validate do
      unless statuses.include?(status.to_sym)
        errors.add(:status, "is incorrect.")
      end
    end

    validate :validate_only_one_update
    validates :progress, numericality: {
      less_than_or_equal_to: 100,
      greated_than_or_equal_to: 0
    }
    attr_accessor :datafiles

    def statuses
      self.class.statuses
    end

    def self.statuses
      [
        STATUS_NONE,
        STATUS_EXECUTING,
        STATUS_PASSED,
        STATUS_FAILED,
        STATUS_ERROR
      ]
    end

    # Return records of individual statues like
      scope STATUS_EXECUTING, -> { where(status: STATUS_EXECUTING) }
      scope STATUS_PASSED, -> { where(status: STATUS_PASSED) }
      scope STATUS_FAILED, -> { where(status: STATUS_FAILED) }
      scope STATUS_ERROR, -> { where(status: STATUS_ERROR) }

    def attached_files
      Dir[File.join(self.directory_path, "*")].map do |path|
        file = File.open(path)
        server_path = file.path

        def file.decompress
          @decompress ||= Tmt::Lib::Gzip.decompress_from(self.path)
        end

        server_filename = server_path.gsub(/.*\//, "")
        {
          server_path: server_path,
          original_filename: read_original_filename(server_filename),
          server_filename: server_filename,
          uuid: server_filename.gsub(/_.*/, ""),
          compressed_file: file,
          is_binary: File.binary?(server_path)
        }
      end
    end

    # Return full path to file which has got properly uuid in name.
    # find_file_path("112h32-1212-21312jlkd-332") #=> "/home/.../112h32-1212-21312jlkd-332_example.html"
    def find_file_path(uuid)
      Dir[File.join(self.directory_path, "*")].map do |path|
        return path if path.include?(uuid)
      end
      nil
    end

    def is_executed
      !(status.nil? && status.empty?)
    end

    def read_original_filename(server_filename)
      ::Base32.decode(server_filename.gsub(/(\A.{37})|(.gz\Z)/, ""))
    end

    def read_original_filename_from_path(path)
      read_original_filename(path.split(/\/|\\/).last)
    end

    def title
      version.comment
    end

    def creator_id
      test_run.creator_id
    end

    def set_executing
      self.status = :executing
    end

    def executed?
      not can_be_executed?
    end

    def can_be_executed?
      (self.status != "passed" && self.status != "failed" && self.status != "error")
    end

    def self.directory_path
      Rails.root.join('private', "execution-result-#{Rails.env}").to_s
    end

    def directory_path
      Rails.root.join('private', "execution-result-#{Rails.env}", self.test_run.id.to_s, self.id.to_s).to_s
    end

    def update_for_user(params)
      if inactive_statuses.include?(params['status'])
        params['progress'] = '100'
      end
      self.update(params)
    end

    private

    def inactive_statuses
      ['failed', 'passed', 'error']
    end

    def validate_only_one_update
      if inactive_statuses.include?(self.status_was.to_s)
        if not self.changes.keys == ['progress']
          errors.add(:status, 'was updated')
        end
      else
        case self.status.to_s
        when 'failed', 'passed', 'error'
          if self.comment.blank? and (datafiles || []).empty?
            errors.add(:comment, "should have some text")
            errors.add(:datafiles, "should have some file")
          end
        when 'executing', 'none'
          unless (datafiles || []).empty?
            errors.add(:datafiles, "should not have some file for executing status")
          end
        else
          errors.add(:status, 'Used status is not defined.')
        end
      end
    end

    def notify_execution_status
      unless self.test_run.nil?
        test_run.reload.touch
        test_run.update_status
      end
    end

    # Files in datafiles will be saving in private directory
    def save_attached_file
      unless Rails.root.blank?
        FileUtils.mkdir_p directory_path
        (self.datafiles || []).each do |datafile|
          original_filename = datafile.original_filename
          filename = "#{SecureRandom.uuid}_#{Base32.encode(original_filename).gsub('=', '')}".first(255 - 3) + ".gz"
          file_path = File.join(directory_path, filename)
          datafile.rewind
          ::Tmt::Lib::Gzip.compress_to(file_path, datafile.read)
        end
      end
    end
  end
end
