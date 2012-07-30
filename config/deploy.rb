set :application, "studyblog"
set :repository,  "/Users/georg.tavonius/Dropbox/coding/studyblog/.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/htdocs/webXX/files/rails/#{application}"
set :keep_releases, 4

role :web, "tovoodo.com"                          # Your HTTP server, Apache/etc
role :app, "tovoodo.com"                          # This may be the same as your `Web` server
role :db,  "tovoodo.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
