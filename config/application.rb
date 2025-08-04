require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module SleepService
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.autoload_paths += %W(
      #{config.root}/app/services
      #{config.root}/app/api
      #{config.root}/app/api/entities
    )

    config.eager_load_paths += %W(
      #{config.root}/app/services
      #{config.root}/app/api
      #{config.root}/app/api/entities
    )
  end
end
