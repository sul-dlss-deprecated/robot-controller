require 'resque/server'
require File.expand_path(File.dirname(__FILE__) + '/./lib/resque/resque-robot-controller')

Resque.redis = 'localhost:6379:0/resque:development'

run Rack::URLMap.new \
  "/"       => Resque::Server.new

