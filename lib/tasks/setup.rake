require 'inifile'
namespace :setup do
  desc "Overwrite the general preferences"
  task :preferences, [:file] => :environment do |t, args|
    ApplicationHelper.load_preferences(args[:file])
  end

end
