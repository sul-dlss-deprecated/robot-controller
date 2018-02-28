# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'robot-controller'

Gem::Specification.new do |s|
  s.name        = 'robot-controller'
  s.version     = RobotController::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Hardy']
  s.email       = ['drh@stanford.edu']
  s.homepage    = 'http://github.com/sul-dlss/robot-controller'
  s.summary     = 'Monitors and controls running workflow robots off of priority queues and within a cluster'
  s.has_rdoc    = true
  s.licenses    = ['ALv2', 'Stanford University']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'bluepill'
  s.add_dependency 'resque', '~> 1.26'
  s.add_dependency 'rake', '>= 10.3'
  s.add_dependency 'whenever', '~> 0.9.2'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'redcarpet' # provides Markdown
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'version_bumper'
end
