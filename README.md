robot-controller
================

Monitors and controls running workflow robots off of priority queues and within a cluster.

## Configuration

In your `Gemfile`, add:

    gem 'robot-controller'

In your `Rakefile`, add:

    require 'resque/tasks'
    
    desc "Environment from boot"
    task :environment do
      require File.expand_path(File.join(File.dirname(__FILE__), 'config', 'boot'))
    end
    
Create the following configuration files based on the examples in `config`:

    config/boot.rb
    config/environments/development.rb
    config/environments/bluepill_development.rb
    config/environments/workflows_development.rb

Create a `config.ru` file as follows:

    require 'resque/server'
    require File.expand_path(File.dirname(__FILE__) + '/./lib/resque/resque-robot-controller')

    Resque.redis = 'localhost:6379:0/resque:development'

    run Rack::URLMap.new \
      "/"       => Resque::Server.new


### Usage

    Usage: controller [ boot | start | status | stop | restart | log | quit ]

    Example:
     % controller boot    # start bluepilld and jobs
     % controller status  # check on status of jobs
     % controller stop    # stop jobs
     % controller quit    # stop bluepilld
