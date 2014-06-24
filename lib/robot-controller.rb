# Monitors and controls running workflow robots off of priority queues and within a cluster.

module RobotController
  # e.g., `1.2.3`
  VERSION = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).strip

  def self.bluepill_config
    File.join(File.dirname(__FILE__), 'robot-controller', 'bluepill.rb')
  end

end