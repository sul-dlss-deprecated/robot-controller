require './lib/resque/plugins/resque_robot_controller/server'

Resque::Server.register Resque::Plugins::ResqueRobotController::Server