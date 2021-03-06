require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArtvsartApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]
    config.autoload_paths += Dir[Rails.root.join('lib', '{*/}')]
    
    config.middleware.insert_before 0, Rack::Cors do
       allow do
         origins 'localhost:3333', 'localhost:3000', 'http://artvsart.io', 'http://www.artvsart.io', 'api.artvsart.io', 'artvsart.io', '127.0.0.1' 
         resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :patch, :delete], credentials: true
       end
     end
    
    config.middleware.use ActionDispatch::Flash
    
    config.middleware.use ActionDispatch::Cookies
    
    config.middleware.use ActionDispatch::Session::CookieStore
     

  end
end

