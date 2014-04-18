require 'capistrano/ext/multistage'

set :user, "deploy"  # The server's user for deploys
set :application, "DrwhoAdmin"
set :repository,  "git@github.com:jasonlu/drwho_admin.git"
set :keep_release, 5
set :use_sudo, false

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :scm_passphrases, ""
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :stages, ["staging", "production"]
set :default_stage, "staging"


namespace :bundle do

  desc "run bundle install and ensure all gem requirements are met"
  task :install do
    run "cd #{current_path} && bundle install  --without=test"
  end

end

# Generate an additional task to fire up the thin clusters

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

namespace :db do
  config = YAML.load_file(File.join('config', 'database.yml'))
  
  desc "Migrate DB"
  task :migrate do
    run "cd #{current_path} && rake db:migrate RAILS_ENV=#{rails_env}"
  end
  
  task :dump do
    
    db_config = config[rails_env]
    
    backup_path = File.join('db', Time.now.strftime("backup_#{db_config['database']}_%Y-%m-%e.sql"))
    on_rollback { delete backup_path, :recursive => false }
    backup_file = File.new(backup_path, 'w+')

    run "mysqldump --default-character-set=utf8 " +
    "--user=#{db_config['username']} " +
    "--password " +
    "-B #{db_config['database']}" do |channel,stream,data|
      if stream == :out
        backup_file.write(data)
        #puts data
      else
        if data =~ /^Enter password:/
          puts data
          channel.send_data(db_config['password'])
          channel.send_data("\n")
        else
          raise Capistrano::Error, "unexpected output from mysqldump: " + data
        end
      end
    end
    #run "mysql -u onlynet -p onlynet_dev | mysqldump -u onlynet -p onlynet_prod"
  end
  
end

namespace :deploy do
  task :start do
    #run "cd #{current_path} && bundle exec thin start -C #{release_path}/config/thin.yml"
    run "cd #{current_path} && bundle exec thin start -C #{thin_config_file}"
  end
  task :stop do
    #run "cd #{current_path} && bundle exec thin stop -C ./config/thin.yml"
    run "cd #{current_path} && bundle exec thin stop -C #{thin_config_file}"
  end
  task :restart, :roles => [:web, :app], :except => { :no_release => true } do
    if remote_file_exists?(thin_pid_file)
      deploy.stop
      deploy.start
      #run "cd #{current_path} && bundle exec thin restart -C #{thin_config_file}"
    else
      deploy.start
    end
    #run "cd #{current_path} && bundle exec thin restart -C ./config/thin.yml"
    #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "My setup here"
  task :setup do
    run "mkdir -p #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids #{deploy_to}/shared/files #{deploy_to}/shared/temp #{deploy_to}/shared/uploads #{deploy_to}/shared/ckeditor_assets #{deploy_to}/shared/config"
    run "chmod g+w #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids #{deploy_to}/shared/files #{deploy_to}/shared/temp #{deploy_to}/shared/uploads #{deploy_to}/shared/ckeditor_assets #{deploy_to}/shared/config"
    deploy.copy_files
  end

  task :copy_files do
    find_servers_for_task(current_task).each do |server|
      #run_locally "rsync -vr --exclude='.DS_Store' public/files #{user}@#{server.host}:#{shared_path}/"
      #run_locally "rsync -vr --exclude='.DS_Store' public/uploads #{user}@#{server.host}:#{shared_path}/"
      #run_locally "rsync -vr --exclude='.DS_Store' public/ckeditor_assets #{user}@#{server.host}:#{shared_path}/"
      run_locally "rsync -vr --exclude='.DS_Store' config/database.yml #{user}@#{server.host}:#{shared_path}/config/"
      run_locally "rsync -vr --exclude='.DS_Store' config/initializers/secret_token.rb #{user}@#{server.host}:#{shared_path}/config/initializers/"
      run_locally "rsync -vr --exclude='.DS_Store' --ignore-existing public/files/* #{user}@#{server.host}:#{static_shared_path}/files"
      run_locally "rsync -vr --exclude='.DS_Store' --ignore-existing public/uploads/* #{user}@#{server.host}:#{static_shared_path}/uploads"
      #run_locally "rsync -vr --exclude='.DS_Store' --ignore-existing public/docs/* #{user}@#{server.host}:#{static_shared_path}/docs"
    end
  end
  

  desc "symlink shared files between releases"
  task :symlink_shared, :roles => [:app, :web] do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    
    run "ln -nfs #{static_shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{static_shared_path}/files #{release_path}/public/files"
    run "ln -nfs #{static_shared_path}/docs #{release_path}/public/docs"
    
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"
    run "ln -nfs #{shared_path}/temp #{release_path}/public/temp"
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/pid #{release_path}/tmp/pid"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"

  end



  task :quick do
    deploy.update
    deploy.restart
  end

  task :warp10 do
    run_locally "git add . && git commit -am 'quick_deploy' && git push"
    deploy.quick
  end
end

namespace :assets do
  task :precompile do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end
  task :clean do
    run "cd #{shared_path} && rm -Rf ./assets/*"
  end
end


after "deploy:create_symlink", "deploy:copy_files", "deploy:symlink_shared","deploy:cleanup"#, "bundle:install"
#before "deploy:symlink_shared", "deploy:copy_files"
#after "deploy:symlink_shared", "deploy:assets:precompile"
#before "deploy:assets:precompile", "bundle:install"
#after "bundle:install", "deploy:migrate"
#before "deploy:restart", "bundle:install"