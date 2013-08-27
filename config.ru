# This file is used by Rack-based servers to start the application.

require 'torquebox-stomp'
use TorqueBox::Stomp::StompJavascriptClientProvider
require ::File.expand_path('../config/environment',  __FILE__)
run KarmaTracker::Application
