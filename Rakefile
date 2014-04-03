require 'rubygems'
require 'rake'
require 'version_bumper'
require 'resque/tasks'
require 'robot-controller/tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

task :default => [ :doc ]