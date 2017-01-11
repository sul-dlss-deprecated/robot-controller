require 'rubygems'
require 'rake'
require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'version_bumper'
require 'robot-controller/tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: [:spec, :rubocop, :yard]
