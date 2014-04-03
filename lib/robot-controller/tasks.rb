desc "Start multiple Resque workers using environment"
task :workers => [ :environment ] do
  threads = []
  (ENV['COUNT'] || '1').to_i.times do
    threads << Thread.new do
      system "rake environment resque:work" # XXX is better way to do this?
    end
  end
  threads.each { |thread| thread.join }
end
