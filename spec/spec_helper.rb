require 'sidekiq/limit_fetch'
require 'celluloid/autostart'
require 'sidekiq/fetch'

Sidekiq.logger = nil
Sidekiq.redis = { url: ENV.fetch('REDIS','redis://127.0.0.1:6379/1'), namespace: ENV['namespace'] }

RSpec.configure do |config|
  config.before :each do
    Sidekiq::Queue.reset_instances!
    Sidekiq.redis do |it|
      clean_redis = ->(queue) do
        it.pipelined do
          it.del "limit_fetch:limit:#{queue}"
          it.del "limit_fetch:process_limit:#{queue}"
          it.del "limit_fetch:busy:#{queue}"
          it.del "limit_fetch:probed:#{queue}"
          it.del "limit_fetch:pause:#{queue}"
          it.del "limit_fetch:block:#{queue}"
        end
      end

      clean_redis.call(name) if defined?(name)
      queues.each(&clean_redis) if defined?(queues) and queues.is_a? Array
    end
  end
end
