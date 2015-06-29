require 'rubygems'
require 'rake'
require 'version_bumper'
require 'robot-controller/tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

task default: [:spec, :yard]
