# verification class
module RobotController
  # Usage:
  #   RobotController::Verify.new('robot1' => 1, 'robot2' => 2, 'robot3' => 0)
  #   => {
  #     'robot1': { state: :up, running: 1 },
  #     'robot2': { state: :down, running: 0 },
  #     'robot3': { state: :not_enabled, running: 0 }
  #   }
  # ----
  #
  # When no errors are detected, the output looks like so:
  #   % bundle exec controller verify
  #   OK
  #
  #   % bundle exec controller verify --verbose
  #   OK robot1 is up
  #   OK robot2 is up
  #   OK robot3 is not enabled
  #   OK robot4 is not enabled
  #
  # If robot2 were down and robot3 were up, the output would look like so:
  #
  #   % bundle exec controller verify
  #   ERROR robot2 is down (0 out of 3 processes running)
  #   ERROR robot3 is not enabled but 1 process is running
  #
  #   % bundle exec controller verify --verbose
  #   OK robot1 is up
  #   ERROR robot2 is down (0 out of 3 processes running)
  #   ERROR robot3 is not enabled but 1 process is running
  #   OK robot4 is not enabled
  #
  # The various states are determined as follows:
  #
  #   If the robot is enabled:
  #     OK: all N processes are running
  #     ERROR: not all N processes are running
  #   If the robot is NOT enabled:
  #     OK: no processes are running
  #     ERROR: 1 or more processes are running
  #   If the robot is unknown by the suite:
  #     ERROR: always
  class Verify
    attr_reader :robots

    # @param [Hash] nprocesses expected number of processes for all robots
    def initialize(nprocesses)
      fail ArgumentError if nprocesses.nil? || !nprocesses.is_a?(Hash)
      fail ArgumentError, 'Empty argument' if nprocesses.size == 0
      @running = nprocesses
      @robots = @running.each_key.to_a
      @status = nil
    end

    # @param [Boolean] reload forces a reload of status information
    # @return [Hash<Hash>] status of all robots
    # {
    #   'robot1' : {
    #     state: :up,
    #     running: 2
    #   },
    #   'robot2' : {
    #     state: :down,
    #     running: 0
    #   },
    #   'robot3' : {
    #     state: :not_enabled,
    #     running: 0
    #   }
    # }
    def verify(reload = true)
      @status = nil if reload
      r = {}
      robots.each do |robot|
        r[robot] = robot_status(robot)
      end
      r
    end

    # @param [String] robot name
    # @return [Integer] number of running processes expected otherwise nil
    def running(robot)
      @running[robot]
    end

    protected

    # @param [String] robot name
    # @return [Hash] { state: :up | :down | :not_enabled, running: n }
    def robot_status(robot)
      if status[robot].nil?
        fail "ERROR: No status information for #{robot}"
      else
        status[robot]
      end
    end

    #
    # @return [Hash] status
    # {
    #   'robot1': {
    #     state: :up,
    #     running: 1
    #   },
    #   'robot2': ...,
    #   'robot3': ...
    # }
    def status
      if @status.nil?
        # run controller_status to get all robot states
        states = self.class.parse_status_output(controller_status)
        fail 'No output from controller status' unless states.size > 0

        # convert states into status metrics for all robots with state
        @status = {}
        robots.each do |robot|
          matches = states.select { |state| state[:robot] == robot }
          @status[robot] = self.class.consolidate_states_into_status(matches)
        end

        # cross-check against all robots
        robots.each do |robot|
          if @status[robot].nil?
            @status[robot] = {
              state: (running(robot) == 0 ? :not_enabled : :unknown),
              running: 0
            }
          elsif @status[robot][:running] != running(robot)
            @status[robot][:state] = :down
          end
        end
      end
      @status
    end

    # Runs 'bundle exec controller status' and returns/yields output
    # @yield [Array[String]] output
    def controller_status
      IO.popen('bundle exec controller status 2>&1').readlines.map(&:strip)
    end

    # -- Class methods --
    class << self
      #
      # @param [Array<String>] output from bundle exec controller status
      # @return [Array<Hash>] status
      # [
      #  {
      #  robot: 'robot123',
      #  nth: 1
      #  pid: 123
      #  state: :down | :up
      #  },
      #  robot: 'robot456',
      #  nth: 1
      #  pid: 456
      #  state: :down | :up
      #  }
      # ]
      def parse_status_output(output)
        output.inject([]) { |a, e| a << parse_status_line(e) }.compact
      end

      #
      # @param [String] line as bluepill outputs them...
      # robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29481): up
      # robot02_01_dor_gisAssemblyWF_author-data(pid:29697): down
      # robot03_01_dor_gisAssemblyWF_author-metadata(pid:29512): unmonitored
      #
      # @return [Hash] status {
      #  robot: 'robot123',
      #  nth: 1
      #  pid: 123
      #  state: :down | :up
      # }
      def parse_status_line(line)
        if line =~ /^robot\d\d_(\d\d)_(.+)\(pid:(\d+)\):\s+(.+)$/
          return {
            nth:   Regexp.last_match[1].to_i,
            robot: Regexp.last_match[2].to_s,
            pid:   Regexp.last_match[3].to_i,
            state: (Regexp.last_match[4].to_s == 'up') ? :up : :down
          }
        end
        nil
      end

      # reduces individuals states into a single status
      def consolidate_states_into_status(statuses)
        if statuses.is_a?(Array) && statuses.size > 0
          # XXX: assumes all statuses are for the same robot
          running = 0
          state = :up
          statuses.each do |status|
            running += 1 if status[:state] == :up
            state = :down unless status[:state] == :up
          end
          {
            state: state,
            running: running
          }
        else
          fail 'No information from bundle exec controller status'
        end
      end
    end
  end
end
