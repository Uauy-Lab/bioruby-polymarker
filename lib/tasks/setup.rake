require 'inifile'
namespace :setup do
  desc "Overwrite the general preferences"
  task :preferences, [:file] => :environment do |t, args|
    myini = IniFile.load(args[:file])
    myini.each_section do |section|
      puts section.inspect
      myini[section].each_pair do |name, val| puts "#{name}\t#{val}"
        pref = Preference.find_or_create_by({ key: name})
        pref.value = val
        pref.save!
      end
    end
  end

end
