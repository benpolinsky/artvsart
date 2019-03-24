source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', "~> 3.8"
gem 'active_model_serializers', "~> 0.10.0"
gem 'figaro'
gem 'friendly_id', '~> 5.2.4' 
gem "paranoia", "~> 2.4.1"
gem 'kaminari', "~> 1.0.0"
# auth
gem 'devise', "~> 4.2.1"
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'cancancan', '~> 1.10' # not sure if im using

gem 'rack-cors'

gem 'whenever', :require => false
gem 'slack-notifier'
gem 'rollbar'

gem 'elo'

# Gateways
gem "discogs-wrapper"
gem 'omdbapi'
gem 'hyperclient'
gem 'hyperresource'
gem 'google-api-client', '~> 0.9'

gem 'rmagick'
gem 'carrierwave'
gem 'fog'
gem 'fog-aws'
gem 'jsonapi-parser', '~> 0.1.1.beta2'
gem 'browser', require: 'browser/browser'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem "factory_bot_rails", "~> 5.0.1"
  gem 'faker'
  gem 'fantaskspec', git: "https://github.com/benpolinsky/fantaskspec.git"
  gem "selenium-webdriver"
  gem 'capybara', "2.3.0"
  gem "capybara-webkit", "1.5.1"
  gem 'launchy'
end

group :test do
  gem "rspec-rails", "~> 3.7.0"
  gem "rspec-core", "~> 3.7.0"
  gem "rspec-support", "~> 3.7.0"
  gem "rspec-expectations", "~> 3.7.0"
  gem "rspec-mocks", "~> 3.7.0"
  gem 'rails-controller-testing'
  gem 'whenever-test'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec', group: :development
  gem 'bullet'
end

gem 'simplecov', :require => false, :group => :test

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.5.1"