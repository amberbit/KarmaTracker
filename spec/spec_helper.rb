ENV["RAILS_ENV"] ||= 'test'
ENV["LANG"] = "en-US"

require File.expand_path("../../config/environment", __FILE__)

require 'database_cleaner'
require 'factory_girl_rails'
require 'pry'
require 'fakeweb'
require 'rspec/rails'
require 'torquebox-no-op'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'
require "email_spec"
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 30


Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.before(:each, register: true) do
    AppConfig.users.allow_register = true
  end

  config.after(:each, register: true) do
    AppConfig.users.allow_register = false
  end

  config.before :suite do
    reset_fakeweb_urls
  end

  config.before(:each, omniauth_google: true) do
    OmniAuth.config.test_mode = true
    OmniAuthMocks.new.mock_google
  end

  config.before(:each, omniauth_github: true) do
    OmniAuth.config.test_mode = true
    OmniAuthMocks.new.mock_github
  end

  config.after(:each, omniauth_google: true) do
    OmniAuth.config.test_mode = false
  end

  config.after(:each, omniauth_github: true) do
    OmniAuth.config.test_mode = false
  end
end

def reset_fakeweb_urls
  # Pivotal Tracker URIs
  FakeWeb.allow_net_connect = false

  FakeWeb.register_uri(:get, 'https://wrong_email:wrong_password@www.pivotaltracker.com/services/v4/me',
    :body => 'Access Denied', :status => ['401', 'Unauthorized'])

  FakeWeb.register_uri(:get, 'https://correct_email%40example.com:correct_password@www.pivotaltracker.com/services/v4/me',
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/me',
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects.xml')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, /https:\/\/www\.pivotaltracker\.com\/services\/v4\/projects\/[0-9]+\/stories/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'stories.xml')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, /https:\/\/www\.pivotaltracker\.com\/services\/v4\/projects\/[0-9]+\/iterations\/current/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'current_iteration.xml')),
    :status => ['200', 'OK'])

  # GitHub URIs
  FakeWeb.register_uri(:post, 'https://wrong_username:wrong_password@api.github.com/authorizations',
    :body => 'Access Denied', :status => ['401', 'Unauthorized'])

  FakeWeb.register_uri(:post, 'https://correct_username%40example.com:correct_password@api.github.com/authorizations',
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'authorization_success.json')),
    :status => ['201', 'OK'])

  FakeWeb.register_uri(:get, 'https://api.github.com/user/subscriptions',
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'repos.json')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/repos\/.*\/.*\/collaborators/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'collaborators.json')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/repos\/.*\/.*\/issues\?state\=open/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'issues.json')),
    :status => ['200', 'OK'])

  FakeWeb.register_uri(:get, /https:\/\/api\.github\.com\/user/,
    :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'git_hub', 'responses', 'user.json')),
    :status => ['200', 'OK'])

end


