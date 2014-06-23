require 'yaml'

class RobotConfigParser
  ROBOT_INSTANCE_MAX = 16

  # parse_instances(1) == 1
  # parse_instances(16) == 16
  # parse_instances(0) == 1
  # parse_instances(99) => RuntimeError
  def parse_instances(n)
    if n > ROBOT_INSTANCE_MAX
      raise RuntimeError, "TooManyInstances: #{n} > #{ROBOT_INSTANCE_MAX}"
    end
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
    return ['default'] if lanes_spec.split(/,/).collect {|l| l.strip}.join('') == ''
    lanes_spec.split(/,/).collect {|l| l.strip }
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

  # main entry point
  def load(env)
    # read the YAML file
    robots_fn = File.join('config', 'environments', "robots_#{env}.yml")
    unless File.file?(robots_fn)
      raise RuntimeError, "FileNotFound: #{robots_fn}"
    end
    
    puts "Loading #{robots_fn}"
    robots =  YAML.load_file(robots_fn)
    # puts robots
  
    # determine current host
    host = `hostname -s`.strip
    # puts host

    # host = 'sul-robots1-dev' # XXX
    unless robots.include?(host)
      raise RuntimeError, "HostMismatch: #{host} not defined in #{robots_fn}"
    end

    # parse YAML lines for host where i is robot[:lane[:instances]]
    r = []
    robots[host].each do |i|  
      robot = i.split(/:/).collect {|j| j.strip}
      robot.each do |j|
        if j.strip == ''
          raise RuntimeError, "SyntaxError: #{i}"
        end
      end
    
      # add defaults
      if robot.size == 1
        robot << 'default'
      end
      if robot.size == 2
        robot << '1'
      end
    
      # build queues for robot instances
      unless robot.size == 3
        raise RuntimeError, "SyntaxError: #{i}"
      end
      robot[2] = parse_instances(robot[2].to_i)
      # puts robot.join(' : ')
      queues = build_queues(robot[0], robot[1])
      # puts queues
  
      r << {:robot => robot[0], :queues => queues, :n => robot[2] }
    end
    r
  end
end

ROBOTS = RobotConfigParser.new.load(ENV['ROBOT_ENVIRONMENT'] || 'development')
# puts ROBOTS