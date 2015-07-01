require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'version_bumper'
require 'robot-controller/tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: [:spec, :rubocop, :yard]
