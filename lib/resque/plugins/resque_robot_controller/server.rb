module Resque
  module Plugins
    module ResqueRobotController

      module Server

        VIEW_PATH = File.join(File.dirname(__FILE__), 'server', 'views')

        def self.registered(app)
          app.get "/robot controller" do
            resquerobotcontroller_view :resquerobotcontroller
          end

          app.helpers do
            def resquerobotcontroller_view(filename, options = {}, locals = {})
              erb(File.read(File.join(::Resque::Plugins::ResqueRobotController::Server::VIEW_PATH, "#{filename}.erb")), options, locals)
            end
          end
          
          app.tabs << "Robot Controller"
        end

      end

    end
  end
end
