ENV["RAILS_ENV"] ||= 'test'
ENV["LANG"] = "en-US"

require File.expand_path("../../config/environment", __FILE__)

require 'database_cleaner'
require 'factory_girl_rails'
require 'pry'
require 'rspec/rails'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

end
