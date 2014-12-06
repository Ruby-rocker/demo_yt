# Production Deploy Config

set :user, 'ubuntu'
#set :domain, 'ec2-54-200-10-210.us-west-2.compute.amazonaws.com'
set :domain, 'ec2-54-186-137-200.us-west-2.compute.amazonaws.com'

set :deploy_to, "/home/ubuntu/railsAppsYestrakStaging"

set :rails_env, "staging"

set :branch, "staging"

role :web, "54.186.137.200"
role :app, "54.186.137.200"
role :db,  "54.186.137.200", :primary => true
role :db,  "54.186.137.200"

after 'deploy:update_code', 'deploy:symlink_uploads', "deploy:migrate"

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

after "deploy:update", "deploy:cleanup"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    #run "sudo /usr/local/bin/allah restart rubyradar_unicorn"
    run "sudo service apache2 restart"
  end
end

namespace :deploy do
  desc "Symlink shared uploads on each release."
  task :symlink_uploads do
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
  end
end

############################
# Whenever cron jobs config
############################
set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}-#{stage}" }
require "whenever/capistrano"