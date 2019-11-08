module CommonHelper
  require "nokogiri"

  def ready(*values)
    values.map { |value| value }
    values.first if values.size == 1
  end

  def http_login(user)
    email = user.email
    pw = user.password
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(email, pw)
  end

  def pretty_xml(string)
    Nokogiri::XML(string).to_xml(encoding: 'utf-8')
  end

  def self.uploaded_file(filename, type='text/plain')
    ::ActionDispatch::Http::UploadedFile.new({
      filename: filename,
      content_type: type,
      tempfile: ::File.new(Rails.root.join('spec', 'files', filename), 'rb')
    })
  end

  def clean_execution_repository
    path = Tmt::Execution.directory_path
    if path =~ /execution-result-test/
      unless ['/', nil, '/**/*', '/*'].include?(path)
        FileUtils.rm_r(path, force: true)
      end
    end
  end

end
