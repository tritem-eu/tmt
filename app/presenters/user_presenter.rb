class UserPresenter < ApplicationPresenter
  presents :user

  def active_projects
    projects = user.projects
    add_tag do |tag|
      if projects.any?
        projects.each_with_index do |project, index|
          tag << link_to(project.name, project)
          tag << ', ' unless index + 1 == projects.size
        end
      else
        tag << show_value('')
      end
    end
  end

  def roles
    user.roles.pluck(:name).join(', ')
  end
end
