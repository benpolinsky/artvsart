source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma'
gem 'active_model_serializers', '~> 0.10'
gem 'figaro'

# auth
gem 'devise'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'cancancan', '~> 1.10' # not sure if im using


gem 'rack-cors'
gem 'hyperclient'
gem 'hyperresource'

# Gateways
gem "discogs-wrapper"
gem 'omdbapi'
gem 'rmagick'
gem 'carrierwave'
gem 'fog'
gem 'fog-aws'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem "factory_girl_rails", "~> 4.0"
  gem 'faker'
  
end

group :test do
  gem "rspec-rails", git: "https://github.com/rspec/rspec-rails.git", branch: "master"
  gem "rspec-core", git: "https://github.com/rspec/rspec-core.git", branch: "master"
  gem "rspec-support", git: "https://github.com/rspec/rspec-support.git", branch: "master"
  gem "rspec-expectations", git: "https://github.com/rspec/rspec-expectations.git", branch: "master"
  gem "rspec-mocks", git: "https://github.com/rspec/rspec-mocks.git", branch: "master"
  gem 'rails-controller-testing'
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
