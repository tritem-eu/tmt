require_relative 'script'
require 'base32'
require 'gzip'

namespace :tmt do
  namespace :execution do
    desc "Change content execution result files from plain to gzip. Change filename to Base32 system"
    task :results_to_gz => :environment do |t, args|
      paths = []
      Dir[File.join(::Tmt::Execution.directory_path, "**", '*')].map do |path|
        if File.file?(path)
          unless path =~ /.gz\Z/
            content = File.open(path, 'rb').read
            server_filename = path.gsub(/.*\//, "")
            uuid = server_filename.gsub(/_.*/, "")
            filename = server_filename.gsub(/\A.{37}/, "")
            filename = "#{uuid}_#{::Base32.encode(filename).gsub('=', '')}".first(255 - 3) + ".gz"
            new_path = File.join(path.gsub(/\/[^\/]*\Z/, ''), filename)
            ::Tmt::Lib::Gzip.compress_to(new_path, content)
            p "created #{new_path}"
            File.delete(path)
            p "deleted #{path}"
          end
        end
      end
    end
  end
end
