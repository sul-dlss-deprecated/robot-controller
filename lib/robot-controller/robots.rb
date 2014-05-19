require 'yaml'

class RobotConfigParser
  ROBOT_INSTANCE_MAX = 16
  LANE_INSTANCE_MAX = 99  # sprintf("%02d") maximum

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

  # parse_lanes('*') == ['*']
  # parse_lanes('0') == [0]
  # parse_lanes('1') == [1]
  # parse_lanes('1-5') == [1,2,3,4,5]
  # parse_lanes('1,2,3') == [1,2,3]
  # parse_lanes('1-5,8') == [1,2,3,4,5,8]
  # parse_lanes('-1') == [0, 1]
  # parse_lanes('100') == RuntimeException
  def parse_lanes(lanes_spec)
    lanes = []
  
    # parse each comma-seperated specification
    lanes_spec.split(/,/).each do |i|
      # this is a range element
      if i =~ /-/
        x = i.split(/-/)
        Range.new(x[0].to_i, x[1].to_i).each do |j|
          lanes << j
        end
      # a wildcard
      elsif i == '*'
        lanes << '*'
      # simple integer
      else
        lanes << i.to_i
      end
    end
  
    # verify that lanes are all within 1 .. LANE_INSTANCE_MAX
    lanes.each do |j|
      if j.is_a?(Integer)
        if j > LANE_INSTANCE_MAX
          raise RuntimeError, "SyntaxError: Lane #{j} > #{LANE_INSTANCE_MAX}"
        elsif j < 0
          raise RuntimeError, "SyntaxError: Lane #{j} < 0"
        end
      end
    end
    lanes
  end

  # build_queues('a','1') => ['a_01']
  # build_queues('a','1,3') => ['a_01', 'a_03']
  # build_queues('a','1-3') => ['a_01', 'a_02', 'a_03']
  def build_queues(robot, lanes)
    queues = []
    parse_lanes(lanes).each do |i|
      queues << [robot, i == '*' ? '*' : sprintf("%02d", i)].join('_')
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
      robot = i.split(/:/)
      robot.each do |j|
        if j.strip == ''
          raise RuntimeError, "SyntaxError: #{i}"
        end
      end
    
      # add defaults
      if robot.size == 1
        robot << '*'
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