robot-controller
================

Monitors and controls running workflow robots off of priority queues and within a cluster.

## Configuration

In your `Gemfile`, add:

    gem 'robot-controller'

In your `Rakefile`, add the following (if you don't want to include the environment unconditionally):

    require 'resque/tasks'
    require 'robot-controller/tasks'
    
Create the following configuration files based on the examples in `example/config`:

    config/boot.rb
    config/environments/development.rb
    config/environments/bluepill_development.rb
    config/environments/workflows_development.rb

### Usage

    Usage: controller [ boot | quit ]
           controller [ start | status | stop | restart | log ] [worker]

    Example:
     % controller boot    # start bluepilld and jobs
     % controller status  # check on status of jobs
     % controller stop    # stop jobs
     % controller quit    # stop bluepilld
