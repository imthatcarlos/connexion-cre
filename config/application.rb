require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Connexion2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    
    config.active_record.time_zone_aware_types = [:datetime]
    
    config.active_record.schema_format = :sql

    # Auto-load bots and its subdirectories
    config.paths.add File.join('app', 'bots'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'bots', '*')]
  end
end
