source 'https://rubygems.org'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


gem 'authlogic'
gem 'declarative_authorization'
gem 'cancan'

gem 'sanitize'
gem 'paperclip', '~> 3.1.2'

#gem "therubyracer", :require => 'v8'

# gem 'nokogiri'

# TODO: maybe replace with simple_form (https://github.com/plataformatec/simple_form/)
gem 'dynamic_form', :git => 'git://github.com/rails/dynamic_form.git'
gem 'simple_form'

gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara', '~>1.1.2', :require => false
  gem 'simplecov', :require => false
end

group :development, :test do
  gem 'rspec-rails'

  gem 'jasmine'
end

group :production do
  gem 'pg'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# To use debugger
# gem 'debugger'
