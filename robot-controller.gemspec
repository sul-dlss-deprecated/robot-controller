# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'robot-controller'

Gem::Specification.new do |s|
  s.name        = "robot-controller"
  s.version     = RobotController::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Darren Hardy"]
  s.email       = ["drh@stanford.edu"]
  s.homepage    = "http://github.com/sul-dlss/robot-controller"
  s.summary     = "Monitors and controls running workflow robots off of priority queues and within a cluster"
  s.has_rdoc    = true
  s.licenses    = ['ALv2', 'Stanford University']
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
 
  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency 'bluepill', '~> 0.0.64'
  s.add_dependency 'resque', '~> 1.25.2'
  
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rack'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'redcarpet' # provides Markdown
  s.add_development_dependency 'version_bumper'
  s.add_development_dependency 'yard'
 
end
