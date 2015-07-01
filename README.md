[![Build Status](https://travis-ci.org/sul-dlss/robot-controller.svg?branch=master)](https://travis-ci.org/sul-dlss/robot-controller)
[![Dependency Status](https://gemnasium.com/sul-dlss/robot-controller.svg)](https://gemnasium.com/sul-dlss/robot-controller)


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

    bundle exec controller boot
    
If you want to *override* the bluepill configuration but still use the 
controller (though NOT recommended), then add:

    config/bluepill.rb

### Usage

    Usage: controller ( boot | quit )
           controller ( start | status | stop | restart | log ) [worker]
           controller verify [--verbose]
           controller [--help]

    Example:
      controller boot    # start bluepilld and jobs
      controller status  # check on status of jobs
      controller verify  # verify robots are running as configured
      controller log robot01_01_dor_accessionWF_descriptive-metadata # view log for worker 
      controller stop    # stop jobs
      controller quit    # stop bluepilld
  
    Environment:
      BLUEPILL_BASEDIR - where bluepill stores its state (default: run/bluepill)
      BLUEPILL_LOGFILE - output log (default: log/bluepill.log)
      ROBOT_ENVIRONMENT - (default: development)

### Changes

* `v1.0.0`: Initial version
* `v1.0.1`: Add 'rake' as dependency
* `v2.0.0`: Added 'verify' command

### `verify` command

You can run the `verify` command with an optional `--verbose` to print out
details about whether the robots processes are running as configured.
To install create a `config/robots.yml` that lists all of the robots in your suite.

When no errors are detected, the output looks like so:

    % bundle exec controller verify
    OK

    % bundle exec controller verify --verbose
    OK robot1 is up (1 running)
    OK robot2 is up (1 running)
    OK robot3 is not enabled (0 running)
    OK robot4 is not enabled (0 running)

If `robot2` were down and `robot3` were up, the output would look something like:

    % bundle exec controller verify
    ERROR robot2 is down (1 of 3 running)
    ERROR robot3 is not enabled (but 1 running)

    % bundle exec controller verify --verbose
    OK robot1 is up (1 running)
    ERROR robot2 is down (1 of 3 running)
    ERROR robot3 is not enabled (but 1 running)
    OK robot4 is not enabled (0 running)

The various states are determined as follows:

- If the robot is enabled:
  - `OK`: all N processes are running
  - `ERROR`: not all N processes are running
- If the robot is NOT enabled:
  - `OK`: no processes are running
  - `ERROR`: 1 or more processes are running
- If the robot is unknown by the suite:
  - `ERROR`: always

NOTE: The queues on which the robots are running are NOT verified.

### Running `verify` command via crontab

In `Capfile` add:

    require 'whenever/capistrano'

In `config/deploy.rb` add:

    set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

In `config/schedule.rb` add:

    every 5.minutes do
      # cannot use :output with Hash/String because we don't want append behavior
      set :output, lambda { '> log/verify.log 2> log/cron.log' }
      set :environment_variable, 'ROBOT_ENVIRONMENT'
      rake 'robots:verify'
    end
