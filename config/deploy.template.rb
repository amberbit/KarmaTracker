set :application, "karmatracker"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "your server domain name here"                          # Your HTTP server, Apache/etc
role :app, "your server domain name here"                          # This may be the same as your `Web` server
role :db,  "your server domain name here", :primary => true        # This is where Rails migrations will run

default_run_options[:pty] = true

set :user, -> { "your username on server here" }
set :group, -> { "your username on server here" }
set :use_sudo, false

set :scm, :git
set :repository,  "git://github.com/amberbit/KarmaTracker.git"

set :deploy_to, -> { "/home/#{user}" } # Change this if you want to deploy to other directory
set :deploy_via, :remote_cache
set :deploy_env, -> { "production" }
set :rails_env, -> { "production" }
set :app_context,       "/"

set :default_environment, {
  'rvmsudo_secure_path' => 1
}

set :rvm_ruby_string, -> { "jruby-1.7.9" }     # use the same ruby as used locally for deployment

before 'deploy', 'rvm:install_rvm'  # update RVM
before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)

require "rvm/capistrano"
require 'bundler/capistrano'

namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :finalize_update do
    # If this task fails, please make sure you put config/database.yml and config/app_config.yml in the shared directory

    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/app_config.yml #{release_path}/config/app_config.yml"
  end

  desc "Start the server"
  task :start do
    run "cd #{current_path} && RAILS_ENV=production bundle exec torquebox deploy"
  end

  task :stop do
    run "cd #{current_path} && RAILS_ENV=production bundle exec torquebox undeploy"
  end

  task :restart do
    run "cd #{current_path} && RAILS_ENV=production bundle exec torquebox deploy"
  end
end
