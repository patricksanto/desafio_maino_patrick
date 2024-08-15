Sidekiq.configure_server do |config|
  redis_url = ENV['REDIS_URL']
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  redis_url = ENV['REDIS_URL']
  config.redis = { url: redis_url }
end
