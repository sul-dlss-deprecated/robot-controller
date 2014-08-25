robot-controller
================

Monitors and controls running workflow robots off of priority queues and within a cluster.

## Configuration

In your `Gemfile`, add:

    gem 'robot-controller'

In your `Rakefile`, add the following (if you don't want to include the environment unconditionally):

    require 'robot-controller/tasks'
    
Create the following configuration files based on the examples in `example/config`:

    config/environments/robots_development.yml
    
Then to use the controller to boot the robots:

    % bundle exec controller boot
    
If you want to *override* the bluepill configuration but still use the 
controller, then add:

    config/bluepill.rb

### Usage

    Usage: controller ( boot | quit )
           controller ( start | status | stop | restart | log ) [worker]
           controller [--help]

    Example:
      % controller boot    # start bluepilld and jobs
      % controller status  # check on status of jobs
      % controller log 1_dor_accessionWF_descriptive-metadata # view log for worker
      % controller stop    # stop jobs
      % controller quit    # stop bluepilld
  
    Environment:
      BLUEPILL_BASEDIR - where bluepill stores its state (default: run/bluepill)
      BLUEPILL_LOGFILE - output log (default: log/bluepill.log)
      ROBOT_ENVIRONMENT - (default: development)

### Changes

* `v1.0.0`: Initial version
* `v1.0.1`: Add 'rake' as dependency
