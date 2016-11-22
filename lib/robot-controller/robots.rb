require 'yaml'

#
module RobotController
  #
  class Parser
    # maximum number of processes a single robot can have
    ROBOT_INSTANCE_MAX = 16

    class << self
      # main entry point
      def load(robots_fn, dir = 'config/environments', host = nil)
        # Validate parameters
        robots_fn = File.join(dir, robots_fn) if dir
        fail "FileNotFound: #{robots_fn}" unless File.file?(robots_fn)

        # read the YAML file with the configuration of all the robots to run
        robots = YAML.load_file(robots_fn)

        # determine current host if not provided
        host ||= `hostname -s`.strip

        # if the config lists this specific host, use it;
        # else check to see if '*' is a matching host
        unless robots.include?(host)
          fail "HostMismatch: #{host} not defined in #{robots_fn}" unless robots.include?('*')
          host = '*'
        end

        # parse the host-specific YAML configuration
        parse_robots_configuration(robots[host])
      end

      # validates that the instances value is within range, e.g.,
      #
      #   instances_valid?(1) == 1
      #   instances_valid?(16) == 16
      #   instances_valid?(0) == 1             # out of range low, enforce minimum
      #   instances_valid?(99) => RuntimeError # out of range high, error out
      def instances_valid?(n)
        fail "TooManyInstances: #{n} > #{ROBOT_INSTANCE_MAX}" if n > ROBOT_INSTANCE_MAX
        n < 1 ? 1 : n
      end

      # parse the lane values designator using the following syntax:
      #
      #   parse_lanes('') == ['default']
      #   parse_lanes(' ') == ['default']
      #   parse_lanes(' , ') == ['default']
      #   parse_lanes(' , ,') == ['default']
      #   parse_lanes('*') == ['*']
      #   parse_lanes('1') == ['1']
      #   parse_lanes('A') == ['A']
      #   parse_lanes('A , B') == ['A', 'B']
      #   parse_lanes('A,B,C') == ['A','B','C']
      #   parse_lanes('A-C,E') == ['A-C', 'E']
      def parse_lanes(lanes_spec)
        lanes = lanes_spec.split(/,/).collect(&:strip).uniq
        lanes.join('') == '' ? ['default'] : lanes
      end

      # generate the queue names for all given lanes, e.g.,
      #
      #   queue_names('z','A') => ['z_A']
      #   queue_names('z','A,C') => ['z_A', 'z_C']
      def queue_names(robot, lanes)
        parse_lanes(lanes).collect { |lane| robot + '_' + lane }
      end

      # parse YAML lines for host where line is robot[:lane[:instances]]
      #
      # @return [Array<Hash>]
      #  [{
      #    robot: 'foo',
      #    queues: ['foo_default'],
      #    n: 2
      #  }, ... ]
      def parse_robots_configuration(robots)
        [].tap do |r|
          robots.each do |line|
            robot = line.split(/:/).collect(&:strip)
            robot.each do |j|
              fail "SyntaxError: '#{line}' is missing arguments" if j.strip == ''
            end

            # add defaults
            robot << 'default' if robot.size == 1
            robot << '1' if robot.size == 2

            # build queues for robot instances
            fail "SyntaxError: '#{line}' is missing arguments" unless robot.size == 3
            robot[2] = instances_valid?(robot[2].to_i)
            queues = queue_names(robot[0], robot[1])

            r << { robot: robot[0], queues: queues, n: robot[2] }
          end
        end
      end
    end
  end
end
