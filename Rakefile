require 'rubygems'
require 'rake'
require 'version_bumper'
require 'resque/tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

task :clean do
  puts 'Cleaning old coverage.data'
  FileUtils.rm('coverage.data') if(File.exists? 'coverage.data')
end

desc "Start multiple Resque workers"
task :workers do
  threads = []
  (ENV['COUNT'] || '1').to_i.times do
    threads << Thread.new do
      system "rake environment resque:work"
    end
  end
  threads.each { |thread| thread.join }
end

desc "Load environment from boot file"
task :environment do
  # needs to load the boot file
  require File.expand_path(File.join(File.dirname(__FILE__), 'config', 'boot'))
end

task :default => [:spec]
