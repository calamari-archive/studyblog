require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.2-p290@studyblog'

set :application, "studyblog"
set :local_repository,  "/Users/georg.tavonius/Dropbox/coding/studyblog/.git"
set :repository, "git@tovoodo.com:studyblog.git"

set :ssh_options, {:forward_agent => true}
set :user, 'calamari'
set :use_sudo, false

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :git_enable_submodules, 1

set :deploy_to, "/var/www/#{application}"
#set :deploy_via, :export
set :keep_releases, 4

role :web, "tovoodo.com"                          # Your HTTP server, Apache/etc
role :app, "tovoodo.com"                          # This may be the same as your `Web` server
role :db,  "tovoodo.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# copy shared files after update
task :update_config, :roles => :app do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end

# create symlink after setup
task :symlink_config, :roles => :app do
  run "mkdir -p /var/www/htdocs/#{user}/html/rails"
  run "ln -nfs #{current_path}/public #{symlink_path}"
end

#after "deploy:setup", :symlink_config
#after "deploy:update_code", :update_config


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
