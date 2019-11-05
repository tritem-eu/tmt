require_relative "seed"

namespace :tmt do
  namespace :seed do
    desc 'Upload default variables for project Sandbox'
    task 'sandbox' => :environment do
      ::Tmt::Tasks::Seed.sandbox
    end
  end
end
