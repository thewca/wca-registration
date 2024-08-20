# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require_relative '../env_config'
require_relative '../app_secrets'

module WcaRegistration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Can't activate 7.2 yet because of 'enqueue_after_transaction_commit?' is not defined in
    # ActiveJob::QueueAdapters::ShoryukenAdapter
    # We still activate config.yjit to get the speedup
    config.yjit = true

    config.autoload_paths += Dir["#{config.root}/lib"]
    config.active_job.queue_adapter = :shoryuken
    config.site_name = 'WCA Registration Service'

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
