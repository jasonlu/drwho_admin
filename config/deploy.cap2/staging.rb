#server "10.10.1.100", :app, :web, :db, :primary => true
server "54.238.130.206", :web
#server "10.10.1.106", :web
set :deploy_to, "/srv/www/admin.onlynet.biz.staging"
set :static_shared_path, "/srv/www/static_html"
set :rails_env, "development"
set :thin_config_file, "./config/thin.staging.yml"
set :thin_pid_file, "#{shared_path}/pids/thin.staging.pid"