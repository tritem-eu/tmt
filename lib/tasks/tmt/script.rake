require_relative 'script'

namespace :tmt do
  namespace :script do
    desc "Upload test cases from directory app_dir/tmp/script-peron-#{Rails.env} (Before doing this, kill thin and run sunspot)"
    task :upload_test_cases, [:show_print] => :environment do |t, args|
      ::Tmt::Tasks::Script.new(verbose: args[:show_print]).upload_test_cases
    end
  end
end
