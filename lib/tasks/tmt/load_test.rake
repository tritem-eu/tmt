require_relative 'script'

namespace :tmt do
  desc "Upload test cases from directory app_dir/tmp/script-peron-#{Rails.env} (Before doing this, kill thin instance)"
  task :load_test => :environment do |t, args|
    if 'development' == Rails.env
      while true
        #Thread.new {
          admin = User.admins.first
          project = Tmt::Project.first
          Tmt::Member.where(project_id: project.id, user_id: admin.id).first_or_create

          agent = Mechanize.new
          agent.user_agent_alias = 'Mac Safari'
          agent.get('http://localhost:3000/users/sign_in')
          form = agent.page.form_with class: 'new_user'
          form.field_with(name: 'user[email]').value = admin.email
          form.field_with(name: 'user[password]').value = 'top-secret'
          form.submit

          while true
            agent.get('http://localhost:3000')
            agent.click(agent.page.at('.project-table a'))
            agent.get("http://localhost:3000/projects/#{project.id}/test-cases/new")
            form = agent.page.form_with id: 'new_test_case'
            name = Time.now.to_s

            form.field_with(name: 'test_case[name]').value = name
            form.submit
            p "User #{admin.name} created test case #{name} for project #{project.name}"
          end
        #}
      end
    end
  end
end
