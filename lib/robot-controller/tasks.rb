require 'resque/tasks'

desc 'Verify that robots are running as configured'
namespace :robots do
  task :verify, :verbose do |t,args|
    args.with_defaults(:verbose => nil)
    system "bundle exec controller verify #{args[:verbose] ? '--verbose' : ''}"
  end
end