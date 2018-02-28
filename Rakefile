require 'rake'
require 'bundler/gem_tasks'
require 'version_bumper'
require 'robot-controller/tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: [:spec, :rubocop]
