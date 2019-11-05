namespace :tmt do
  namespace :agent do
    def red(text)
      "\033[31m#{text}\033[0m"
    end

    def green(text)
      "\033[32m#{text}\033[0m"
    end

    desc "Prepare anteroom and git repository for Agent"
    task prepare: :environment do
      environment = Rails.env.to_sym
      ::Tmt::Agent::Config.remove_anteroom(environment)
      ::Tmt::Agent::Config.create_anteroom(environment)

      ::Tmt::Agent::Config.remove_repository(environment)
      ::Tmt::Agent::Config.create_repository(environment)
    end

    desc "Check DB"
    task check: :environment do
      anteroom_path = ::Tmt::Agent::Config.anteroom_path(Rails.env.to_sym)
      records_ids = ::Tmt::TestCaseVersion.where(revision: nil).ids
      files_ids = Dir[::Tmt::Agent::Config.anteroom_path(Rails.env.to_sym) + '/*'].map {|path| path.split('/').last.to_i}

      puts "All records without revision have not files in directory #{anteroom_path}"
      puts "TestCaseVersion ids - anteroom files ids"
      result = (records_ids - files_ids).first(30)
      puts (result.empty? ? green("  OK") : red(result))

      puts "All files in dictionary #{anteroom_path} are defined in DB when array is empy. (Anteroom File ids - TestCaseVersion ids)"
      result = (files_ids - records_ids).first(30)
      puts (result.empty? ? green("  OK") : red(result))
    end
  end
end
