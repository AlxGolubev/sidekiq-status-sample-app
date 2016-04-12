require 'redis'

$redis = Redis.new url: "redis://127.0.0.1/0",
                   namespace: "sidekiq_status_app_#{Rails.env}"
