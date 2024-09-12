# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require_relative '../env_config'
require_relative '../app_secrets'

ENV['SECRET_KEY_BASE'] ||= AppSecrets.SECRET_KEY_BASE

module WcaRegistration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
    config.active_job.enqueue_after_transaction_commit = :never
    config.secret_key_base = AppSecrets.SECRET_KEY_BASE

    config.autoload_paths += Dir["#{config.root}/lib"]
    config.active_job.queue_adapter = :shoryuken
    config.site_name = 'WCA Registration Service'

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
