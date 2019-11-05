class Tmt::ScriptsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize! :script, current_user
    @projects = current_user.projects
  end

  def execute
    @project = ::Tmt::Project.find(params[:script][:project_id])
    case params[:script][:engine]
    when 'import_versions'
      authorize! :member, @project

      buffer = Zip::OutputStream.write_buffer do |zip|
        @project.test_cases.each do |test_case|
          test_case.versions.each do |version|
            zip.put_next_entry(File.join(test_case.id.to_s, version.file_name))
            zip.write version.content
          end
        end
      end
      send_data buffer.string, filename: "#{@project.id}_#{Time.now.to_s.first(19).gsub(/[^\d]*/, '')}.zip", type: 'application/octet-stream'
    else

    end
  end

end
