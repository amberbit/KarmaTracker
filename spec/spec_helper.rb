ENV["RAILS_ENV"] ||= 'test'
ENV["LANG"] = "en-US"

require File.expand_path("../../config/environment", __FILE__)
%w[rails/application database_cleaner factory_girl_rails pry].each{|f| require f}

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each {|f| require f}

DatabaseCleaner.strategy = :transaction
