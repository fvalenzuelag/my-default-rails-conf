# Capistrano Configuration
##########################

require "bundler/capistrano"
require "capistrano/cli"

# Use SSH
default_run_options[:pty] = true
default_environment["RAILS_ENV"] = 'production'
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = true

# General
set :application,         "application"
set :domain,              "www.application.com"
set :deploy_to,           "/var/www/#{domain}"
set :repository_cache,    "#{application}_cache"
set :environment,         "production"
set :stage,               :production

# Git
set :scm,                 :git
set :repository,          "https://github.com/code/application.git"
set :branch,              "master"
set :keep_releases,       3
set :deploy_via,          :remote_cache

# SSH
set :ssh_options,         { :forward_agent => true }
set :user,                "user"
set :runner,              "user"
set :use_sudo,            false

role :web,                domain
role :app,                domain
role :db,                 domain, :primary => true

task :tail, :roles => :app do
  stream "tail #{shared_path}/log/#{stage}.log"
end

task :tailf, :roles => :app do
  stream "tail -f #{shared_path}/log/#{stage}.log"
end

task :console, :roles => :app do
  host = roles[:app].servers.first
  exec "ssh -l #{user} #{host} -t 'source ~/.profile && cd #{current_path} && rbenv rehash && ./script/rails console #{rails_env}'"
end

task :dbconsole, :roles => :app do
  host = roles[:db].servers.first
  exec "ssh -l #{user} #{host} -t 'source ~/.profile && cd #{current_path} && rails dbconsole #{rails_env}'"
end

namespace :unicorn do

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D -E production"
  end

  desc "Restart unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
  end

end

after 'deploy:create_symlink', 'deploy:cleanup'
