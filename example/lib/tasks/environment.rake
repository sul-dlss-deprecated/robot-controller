desc "Load environment from boot file"
task :environment do
  # needs to load the boot file
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'boot'))
end
