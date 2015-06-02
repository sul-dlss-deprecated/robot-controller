WORKDIR = Dir.pwd

robot_environment = ENV['ROBOT_ENVIRONMENT'] || 'development'
require 'robot-controller/robots'
ROBOTS = RobotConfigParser.new.load("robots_#{robot_environment}.yml")
#
# Expect ROBOTS = [
#  {:robot => 'x', :queues => ['a', 'b'], :n => 1}
#  {:robot => 'z', :queues => ['b'], :n => 3}
# ]
#

# set application name to parent directory name
Bluepill.application File.basename(File.dirname(File.dirname(WORKDIR))),
                     log_file: "#{WORKDIR}/log/bluepill.log" do |app|
  app.working_dir = WORKDIR
  ROBOTS.each_index do |i|
    ROBOTS[i][:n].to_i.times do |j|
      # prefix process name with index number to prevent duplicate process names
      prefix = sprintf('robot%02d_%02d', i + 1, j + 1)
      app.process("#{prefix}_#{ROBOTS[i][:robot]}") do |process|
        puts "Creating robot #{process.name}"

        # queue order is *VERY* important
        queues = ROBOTS[i][:queues].join(',')

        # use environment for these resque variables
        process.environment = {
          'TERM_CHILD' => '1', # TERM, KILL, USR1 sent to worker process if running
          'RESQUE_TERM_TIMEOUT' => '10.0', # seconds to wait before sending KILL after TERM
          'QUEUES' => queues,
          'ROBOT_ENVIRONMENT' => robot_environment,
          'INTERVAL' => '5'
        }
        process.environment['VERBOSE'] = 'yes' if ENV['ROBOT_VERBOSE'] == 'yes'
        process.environment['VVERBOSE'] = 'yes' if ENV['ROBOT_VVERBOSE'] == 'yes'

        # process configuration
        process.group = robot_environment
        process.stdout = process.stderr = "#{WORKDIR}/log/#{ROBOTS[i][:robot]}.log"

        # spawn worker processes using robot-controller
        process.start_command = 'rake environment resque:work'

        # we use bluepill to daemonize the resque workers rather than using
        # resque's BACKGROUND flag
        process.daemonize = true

        # bluepill manages pid files
        # process.pid_file = "#{WORKDIR}/run/#{process.name}.pid"

        # graceful stops
        process.stop_grace_time = 360.seconds # must be greater than stop_signals total
        process.stop_signals = [
          :quit, 300.seconds, # waits for jobs, then exits gracefully
          :term, 10.seconds,  # kills jobs and exits
          :kill               # no mercy
        ]

        # process monitoring

        # backoff if process is flapping between states
        # process.checks :flapping,
        #                :times => 2, :within => 30.seconds,
        #                :retry_in => 7.seconds

        # restart if process runs for longer than 15 mins of CPU time
        # process.checks :running_time,
        #                :every => 5.minutes, :below => 15.minutes

        # restart if CPU usage > 75% for 3 times, check every 10 seconds
        # process.checks :cpu_usage,
        #                :every => 10.seconds,
        #                :below => 75, :times => 3,
        #                :include_children => true
        #
        # restart the process or any of its children
        # if MEM usage > 100MB for 3 times, check every 10 seconds
        # process.checks :mem_usage,
        #                :every => 10.seconds,
        #                :below => 100.megabytes, :times => 3,
        #                :include_children => true

        # NOTE: there is an implicit process.keepalive
      end
    end
  end
end
