$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['ROBOT_ENVIRONMENT'] ||= 'development'
ENV['ROBOT_LOG'] ||= '/dev/null'
ENV['ROBOT_LOG_LEVEL'] ||= 'debug'

require 'coveralls'
Coveralls.wear!
require 'simplecov'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec'
end

require 'bundler/setup'
Bundler.require(:default, :development)

RSpec.configure do |_config|
end
