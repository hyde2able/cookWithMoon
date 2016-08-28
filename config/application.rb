require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CookWithMoon
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Tokyo'
    # DB保存時のタイムゾーンをJSTに変更
    config.active_record.default_timezone = :local

    # config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.orm :active_record
    end

    config.autoload_paths += Dir["#{config.root}/lib/**/*"]
  end
end
