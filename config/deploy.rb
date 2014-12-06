# Common deploy configuration
require 'bundler/capistrano'
require 'rvm/capistrano'
require 'delayed/recipes'
before "deploy:assets:precompile", "bundle:install"


set :application, "yestrak"
#set :repository,  "https://softweb:softweb#456@github.com/softweb/vizicall.git"
set :repository,  "https://softweb:softwebror#123@github.com/softweb/yestrak.git"
#set :branch, "events"

set :scm, :git
set :deploy_via, :remote_cache
set :rvm_type, :user

set :keep_releases, 3
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
#ssh_options[:keys] = ["/home/shweta/railsProjects/zachyestrak.pem"]
#ssh_options[:keys] = ["/home/mehul/Desktop/zachyestrak.pem"]
ssh_options[:keys] = ["/home/esha/zachyestrak.pem"]
