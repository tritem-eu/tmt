class Tmt::Set < ActiveRecord::Base
  belongs_to :parent, class_name: "Tmt::Set"
  belongs_to :project, class_name: "Tmt::Project"
  has_many :test_cases_sets, class_name: "Tmt::TestCasesSets", dependent: :destroy
  has_many :test_cases, through: :test_cases_sets
  # return array of sets which are children of self
  has_many :children, class_name: "Tmt::Set", foreign_key: :parent_id

  before_destroy :valid_delete_record

  validates :name, presence: true
  validates :project_id, presence: true
  validate do
    if posterity_ids.include?(self.parent_id)
      errors.add(:parent_id, "You can not add posterity as parent")
    end
  end

  def posterity_ids
    result = ::Tmt::Set.where(id: self.id).ids
    ids = result
    while true
      ids = ::Tmt::Set.where(parent_id: ids).ids
      result += ids
      break if ids.empty?
    end
    result
  end

  def posterity_test_cases_for(project=nil)
    test_case_ids = ::Tmt::TestCasesSets.where(set_id: posterity_ids).map { |record| record.test_case_id }
    if project
      project.test_cases.where(id: test_case_ids)
    else
      ::Tmt::TestCase.where(id: test_case_ids)
    end
  end

  def self.hash_tree(project, test_cases=nil)
    if test_cases.nil?
      test_cases = Tmt::TestCase.undeleted.where(project: project)
    end
    hash_test_cases = {}
    test_cases.each do |test_case|
      hash_test_cases[test_case.id] = test_case
    end
    test_cases_sets = Tmt::TestCasesSets.all
    result = {}
    Tmt::TestCasesSets.all.each do |entry|
      result[entry.set_id] ||= []
      test_case = hash_test_cases[entry.test_case_id]

      result[entry.set_id] << test_case if test_case
    end
    hash_test_cases_sets = result

    sets = self.where(project: project)
    hash_sets = {}
    parents = {}
    sets.each do |set|
      hash_sets[set.id] = set
      parents[set.parent_id] ||= []
      parents[set.parent_id] << set.id
    end

    def parents.tree_for(set_id, hash_sets, hash_test_cases_sets)
      result = {
        children: [],
        id: set_id,
        object: hash_sets[set_id],
        test_cases: hash_test_cases_sets[set_id] || []}
      (self[set_id] || []).each do |id|
        result[:children] << tree_for(id, hash_sets, hash_test_cases_sets)
      end
      result
    end
    parents.tree_for(nil, hash_sets, hash_test_cases_sets)
  end

  def self.all_test_cases_in_branch(hash_tree)
    result = hash_tree[:test_cases].size
    hash_tree[:children].each do |child|
      result += all_test_cases_in_branch(child)
    end
    result
  end

  def generate_zip
    sets = Tmt::Set.includes(:test_cases).where(id: self.posterity_ids)
    buffer = ::Zip::OutputStream.write_buffer do |zip|
      self.posterity_zip("", zip)
    end
    buffer.string
  end

  def posterity_zip(directory, zip)
    self.children.each do |children|
      children.posterity_zip(File.join(directory, parse_filename(self.name)).to_s.gsub(/^\//, ''), zip)
    end

    zip.put_next_entry((File.join(directory, self.name).to_s + "/").to_s.gsub(/^\//, ''))

    self.test_cases.each do |test_case|
      test_case.versions.order(created_at: :desc).each_with_index do |version, index|
        if index.zero?
          zip.put_next_entry(File.join( directory, parse_filename(self.name), "#{test_case.id}-#{parse_filename(version.file_name)}").to_s.gsub(/^\//, ''))
          zip.write version.content
        end
      end
    end
  end

  def self.parse_filename(string)
    string.gsub(/[^\w^\.^\-^\ ]/, '_').gsub(/_+/, '_').gsub(/\.+/, '.')
  end

  # It should return all ancestors in a straight line, all siblings and all aunts
  # without itself
  def sets_for_select
    result = []
    parent = self.parent
    grand_parent_id = (parent ? parent.parent_id : nil)
    result += self.project.sets.where(parent_id: [self.parent_id, grand_parent_id])
    while parent
      result << parent
      parent = parent.parent
    end
    result -= [self]
    result.uniq
  end

  private

  def parse_filename(string)
    self.class.parse_filename(string)
  end

  def valid_delete_record
    unless self.children.empty?
      errors.add(:base, "The record has got children")
      return false
    end
  end

end
