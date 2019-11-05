module Tmt
  class Member < ActiveRecord::Base
    belongs_to :project, class_name: "::Tmt::Project"
    belongs_to :user, class_name: '::User'
    belongs_to :current_test_run, class_name: '::Tmt::TestRun'
    belongs_to :current_test_case, class_name: '::Tmt::TestCase'

    validates :user, { presence: true }
    validates :project_id, presence: true, uniqueness: {scope: :user_id, message: "The user and project should be unique"}

    serialize :set_ids
    serialize :nav_tab
    serialize :filters

    after_initialize do
      self.is_active ||= false
    end

    scope :for_project, -> (project_id) { where(project_id: project_id, is_active: true) }

    # Return hash with key of user id and value of objec ProjectMember
    def self.members_with_objects(project_id)
      result = {}
      self.for_project(project_id).each do |member|
        result[member.user_id] = member
      end
      result
    end

    def set_nav_tab(category, value)
      result = self.nav_tab ||= {}
      case category.to_s
      when 'execution'
        result[category] = value.to_sym if ['list', 'sets'].include?(value.to_s)
      when 'test_case'
        result[category] = value.to_sym if ['flat', 'tree'].include?(value.to_s)
      else

      end
      self.update(nav_tab: result)
    end

    def user_id
      user ? user.id : nil
    end

    def get_nav_tab(category)
      (self.nav_tab || {})[category] || :flat
    end

    def add_set_id(set_ids, id, with_posterity)
      return unless id
      self.set_ids ||= []

      if with_posterity
        set = Tmt::Set.where(id: id).first
        if set
          self.set_ids += set.posterity_ids
        end
      else
        self.set_ids += [id]
      end
      self.set_ids.map!(&:to_s).uniq!
      self.set_ids &= set_ids
      self.save
    end

    def remove_set_id(set_ids, id)
      if id
        self.set_ids ||= []
        self.set_ids -= [id]
        self.set_ids &= set_ids
        self.save
      end
    end

    def set_inactive
      self.update(is_active: false)
    end

    # input:
    #   test_runs - list all test cases undeleted form x project
    #   options - hash with keys: add_set_id and with_posterity or remove_set_id
    def updated_set_ids(sets=nil, options={})
      ids = (sets || []).map(&:id).map(&:to_s)
      add_set_id(ids, options[:add_set_id], options[:with_posterity])
      remove_set_id(ids, options[:remove_set_id])
      self.reload.set_ids || []
    end

    # input:
    #   params: hash of params from reqest
    # output:
    #   current hash of parameters
    def set_test_case_search(params)
      result = self.test_case_search
      result ||= {}
      if params['search'] or params['creator_ids'] or params['type_ids']
        result['search'] = params['search']
        result['creator_ids'] = params['creator_ids']
        result['type_ids'] = params['status_ids']
      end
      self.update(test_case_search: result)
      self.test_case_search
    end
  end
end
