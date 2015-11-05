$:.unshift(File.expand_path("lib", __FILE__))
require 'domain_name_validator/update_zones'

task default: :prepare

task :prepare do
  Rake::Task['zones:update'].invoke
end

namespace :zones do
  task :update do
    DomainNameValidator.update_zones
  end
end
