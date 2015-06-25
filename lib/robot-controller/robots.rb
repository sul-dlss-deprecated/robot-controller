require 'yaml'

#
module RobotController
  #
  class Parser
    ROBOT_INSTANCE_MAX = 16

    class << self
      # main entry point
      def load(robots_fn, dir = 'config/environments', host = nil)
        # Validate parameters
        robots_fn = File.join(dir, robots_fn) if dir
        fail "FileNotFound: #{robots_fn}" unless File.file?(robots_fn)

        # read the YAML file
        # puts "Loading #{robots_fn}"
        robots =  YAML.load_file(robots_fn)
        # puts robots

        # determine current host
        host = `hostname -s`.strip unless host
        # puts host

        # host = 'sul-robots1-dev' # XXX
        fail "HostMismatch: #{host} not defined in #{robots_fn}" unless robots.include?(host) || robots.include?('*')
        host = '*' unless robots.include?(host)

        parse_yaml(robots[host])
      end

      # parse_instances(1) == 1
      # parse_instances(16) == 16
      # parse_instances(0) == 1
      # parse_instances(99) => RuntimeError
      def parse_instances(n)
        fail "TooManyInstances: #{n} > #{ROBOT_INSTANCE_MAX}" if n > ROBOT_INSTANCE_MAX
        n = 1 if n < 1
        n
      end

      # parse_lanes('') == ['default']
      # parse_lanes(' ') == ['default']
      # parse_lanes(' , ') == ['default']
      # parse_lanes(' , ,') == ['default']
      # parse_lanes('*') == ['*']
      # parse_lanes('1') == ['1']
      # parse_lanes('A') == ['A']
      # parse_lanes('A , B') == ['A', 'B']
      # parse_lanes('A,B,C') == ['A','B','C']
      # parse_lanes('A-C,E') == ['A-C', 'E']
      def parse_lanes(lanes_spec)
        return ['default'] if lanes_spec.split(/,/).collect(&:strip).join('') == ''
        lanes_spec.split(/,/).collect(&:strip).uniq
      end

      # build_queues('z','A') => ['z_A']
      # build_queues('z','A,C') => ['z_A', 'z_C']
      def build_queues(robot, lanes)
        queues = []
        parse_lanes(lanes).each do |i|
          queues << [robot, i].join('_')
        end
        queues
      end

      def parse_yaml(robots)
        # parse YAML lines for host where i is robot[:lane[:instances]]
        r = []
        robots.each do |i|
          robot = i.split(/:/).collect(&:strip)
          robot.each do |j|
            fail "SyntaxError: #{i}" if j.strip == ''
          end

          # add defaults
          robot << 'default' if robot.size == 1
          robot << '1' if robot.size == 2

          # build queues for robot instances
          fail "SyntaxError: #{i}" unless robot.size == 3
          robot[2] = parse_instances(robot[2].to_i)
          # puts robot.join(' : ')
          queues = build_queues(robot[0], robot[1])
          # puts queues

          r << { robot: robot[0], queues: queues, n: robot[2] }
        end
        r
      end
    end
  end
end
