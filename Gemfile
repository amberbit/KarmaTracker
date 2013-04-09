source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'rails-api'

gem 'activerecord-jdbc-adapter'
gem 'activerecord-jdbcpostgresql-adapter'

gem 'torquebox'
gem 'torquebox-server', require: false
gem 'torquebox-stomp', require: false
gem 'torquebox-messaging'

gem 'nokogiri'
gem 'nori'

gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'

group :test do
  gem 'rspec-rails', git: 'https://github.com/rspec/rspec-rails.git', ref: 'ee3f224c61cac7d4de919a23945418fd07ada7c6'
  gem 'database_cleaner', require: false
  gem 'facon', require: false
  gem 'nullobject', require: false
  gem 'factory_girl_rails'
  gem 'fakeweb', require: false
end

group :development, :test do
  gem 'pry'
end
