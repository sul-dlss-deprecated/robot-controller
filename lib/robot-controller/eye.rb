require 'robot-controller'

# current directory
WORKDIR = Dir.pwd

# setup robots configuration
robot_environment = ENV['ROBOT_ENVIRONMENT'] || 'development'
ROBOTS = RobotController::Parser.load("robots_#{robot_environment}.yml")
#
# Expect ROBOTS = [
#  {:robot => 'x', :queues => ['a', 'b'], :n => 1}
#  {:robot => 'z', :queues => ['b'], :n => 3}
# ]
#

# set application name to parent directory name
Eye.application File.basename(File.dirname(File.dirname(WORKDIR))),
                log_file: "#{WORKDIR}/log/eye.log" do
  app.working_dir = WORKDIR

  env 'TERM_CHILD' => '1', # TERM, KILL, USR1 sent to worker process if running
      'RESQUE_TERM_TIMEOUT' => '10.0', # seconds to wait before sending KILL after TERM
      'INTERVAL' => '5',
      'ROBOT_ENVIRONMENT' => robot_environment

  env 'VERBOSE' => 'yes' if ENV['ROBOT_VERBOSE'] == 'yes'
  env 'VVERBOSE' => 'yes' if ENV['ROBOT_VVERBOSE'] == 'yes'

  group robot_environment do
    ROBOTS.each_index do |i|
      group ROBOTS[i][:robot] do
        ROBOTS[i][:n].to_i.times do |j|
          # prefix process name with index number to prevent duplicate process names
          prefix = format('robot%02d_%02d', i + 1, j + 1)

          process("#{prefix}_#{ROBOTS[i][:robot]}") do
            puts "Creating robot #{process.name}"

            # queue order is *VERY* important
            queues = ROBOTS[i][:queues].join(',')

            # use environment for these resque variables
            env 'QUEUES' => queues

            # process configuration
            stdall "#{WORKDIR}/log/#{ROBOTS[i][:robot]}.log"

            # spawn worker processes using robot-controller
            start_command 'rake environment resque:work'

            # we use eye to daemonize the resque workers rather than using
            # resque's BACKGROUND flag
            daemonize true

            # graceful stops
            stop_grace 360.seconds
            stop_signals [:QUIT, 300.seconds, :TERM, 10.seconds, :KILL]
          end
        end
      end
    end
  end
end
