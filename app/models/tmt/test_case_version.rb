class Tmt::TestCaseVersion < ActiveRecord::Base
  require 'tempfile'
  NO_FILE_REGEX = /[^([:alpha:]0-9\-_\ \.')]/

  before_validation do
    if self.id.nil?
      if self.datafile.kind_of?(String)
        filename = self.comment.gsub(NO_FILE_REGEX, '_')
        file = Tempfile.new(filename)
        file.write(self.datafile)
        self.datafile = ::ActionDispatch::Http::UploadedFile.new({
          filename: "script-#{filename}",
          content_type: 'text/plain',
          tempfile: file
        })
      end
    end
  end

  validates :comment, {
    presence: true,
    format: {
      with: NAME_REGEX,
      message: "have to consist any of the following characters: words or ASCII"
    }
  }

  validate do
    validate_attribute_length :comment, from: 0
  end

  validates :author, {presence: true}
  #validates :test_case_id, {presence: true}

  validate :should_exist_datafile_and_has_limit

  validate :validate_extension_of_file

  validate do
    if self.id.nil? and not self.test_case.nil?
      current_version = self.test_case.versions.last
      if current_version and datafile
        current_md5 = ::Digest::MD5.hexdigest(current_version.content)
        datafile.rewind
        new_md5 = ::Digest::MD5.hexdigest(datafile.read)
        if current_md5 == new_md5
          errors.add(:datafile, I18n.t(:has_the_same_content_as_, scope: [:models, :test_case_version]))
        end
      end
    end
  end

  validate do
    self.errors.add(:revision, I18n.t(:was_saved, scope: [:models, :test_case_version])) unless self.revision_was.blank?
  end

  before_create :set_file_name
  before_create :set_file_size

  after_create :save_datafile, :set_current_version_id_in_test_case

  belongs_to :test_case, class_name: "Tmt::TestCase", counter_cache: :versions_count
  belongs_to :author, class_name: "User", foreign_key: :author_id

  has_many :executions, class_name: "Tmt::Execution", foreign_key: :version_id
  has_many :test_runs, class_name: "Tmt::TestRun", through: :executions
  has_one :project, class_name: 'Tmt::Project', through: :test_case

  attr_accessor :datafile
  attr_accessor :new_test_case

  # Return true if test case has got type with upload file
  # Another situation (User send script) method should return false
  def file?
    test_case.type.has_file
  end

  def md5
    ::Digest::MD5.hexdigest(self.content)
  end

  # Return git repository where is saved file
  def repository_path
    File.join(Tmt::Agent::Config.repository_path(Rails.env.to_sym), self.id.to_s)
  end

  def anteroom_path
    File.join(Tmt::Agent::Config.anteroom_path(Rails.env.to_sym), self.id.to_s)
  end

  # Return content of file from repository or anteroom
  def content
    unless revision
      begin
        return File.open(anteroom_path, 'rb').read
      rescue
      end
    end
    self.reload
    Tmt::Agent::Machine.show_content(self.revision, self.test_case.id)
  end

  private

  def save_datafile
    unless self.datafile.nil?
      File.open(anteroom_path, "wb") do |f|
        datafile.rewind
        f.write(datafile.read)
      end
      self.test_case.touch
    end
  end

  # After creating the version, application has to set current_version_id column of test_case record
  def set_current_version_id_in_test_case
    if self.id
      if self.test_case
        if not self.test_case.current_version_id == self.id
          self.test_case.update(current_version_id: self.id)
        end
      end
    end
  end

  def should_exist_datafile_and_has_limit
    if self.id.nil?
      if datafile.blank?
        errors.add(:datafile, I18n.t(:dont_added_file, scope: [:models, :test_case_version]))
      else
        file_size = ::Tmt::Cfg.first.file_size
        if datafile.size > file_size*(2**10)*(2**10)
          errors.add(:datafile, I18n.t(:file_couldnt_be_larger_than_mb, scope: [:models, :test_case_version], file_size: file_size))
        else
          return true
        end
      end
    else
      true
    end
  end

  # Before create should set name of file
  def set_file_name
    self.file_name = datafile.original_filename
  end

  # Before create should set size of file
  def set_file_size
    self.file_size = datafile.size
  end

  def validate_extension_of_file
    new_test_case = self.new_test_case || self.test_case
    if datafile and new_test_case.type_file?
      type_extension = new_test_case.type_extension
      unless type_extension.blank?
        unless datafile.original_filename =~ /.+.#{type_extension}\Z/
          errors.add(:datafile, I18n.t(:should_has_got_extension, scope: [:models, :test_case_version], type: type_extension))
        end
      end
    end
  end
end
