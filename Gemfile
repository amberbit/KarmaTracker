source 'https://rubygems.org'
source 'http://torquebox.org/rubygems/'

gem 'rails', '3.2.16'
gem 'rails-api'
gem 'jbuilder', '~> 1.5.0'

gem 'activerecord-jdbc-adapter', '~> 1.2.9.1'
gem 'activerecord-jdbcpostgresql-adapter'

gem 'torquebox', '2.3.0'
gem 'torquebox-server', '2.3.0', require: false
gem 'torquebox-stomp', '2.3.0', require: false
gem 'torquebox-messaging', '2.3.0'

gem 'nokogiri'
gem 'nori'

gem 'zurb-foundation', '~> 4.0.0'
gem 'coffee-rails'
gem 'sass-rails',   '~> 3.2.6'
gem 'uglifier', '>= 1.0.3'

#elasticsearch
gem 'rest-client'
gem 'flex-rails'

gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'
gem 'amberbit-config'
gem 'jruby-openssl'
gem 'will_paginate', '~> 3.0.5'

#Acts as List for db task positioning
gem 'acts_as_list'

#OmniAuth: Google, GitHub
gem 'omniauth', '~> 1.1.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-github', '~> 1.1.1'


group :test do
  gem 'rspec-rails', git: 'https://github.com/rspec/rspec-rails.git', ref: 'ee3f224c61cac7d4de919a23945418fd07ada7c6'
  gem 'database_cleaner', require: false
  gem 'facon', require: false
  gem 'nullobject', require: false
  gem 'factory_girl_rails', '~> 4.3.0'
  gem 'fakeweb', require: false
  gem 'torquebox-no-op', '2.3.0', require: false
  gem 'timecop', require: false
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'email_spec'
  gem 'capybara-screenshot'
end

group :development, :test do
  gem 'pry'
  gem 'capistrano', require: false
  gem 'capistrano-ext', require: false
  gem 'rvm', require: false
  gem 'rvm-capistrano', require: false
end

group :development do
  gem 'rails-erd'
  gem "letter_opener"
  gem 'letter_opener_web', '~> 1.1.0'
  gem 'brakeman', require: false
end
