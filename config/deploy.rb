# config valid only for Capistrano 3.1
lock '3.2.1'

# deploy:starting    - start a deployment, make sure everything is ready
# deploy:started     - started hook (for custom tasks)
# deploy:updating    - update server(s) with a new release
# deploy:updated     - updated hook
# deploy:publishing  - publish the new release
# deploy:published   - published hook
# deploy:finishing   - finish the deployment, clean up everything
# deploy:finished    - finished hook

set :application, 'drwho_admin'
set :repo_url, "git@github.com:jasonlu/drwho_admin.git"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'update_submodule'
  task :update_submodule do
    on roles(:app) do |host|
      execute :git, "submodule init"
      
      
    end
  end

  desc 'Create symlink'
  task :create_symlink do
    on roles(:app) do |host|
      execute :ln, "-s #{fetch :static_shares}/config/database.yml #{fetch :release_path}/config/database.yml"
      execute :ln, "-s #{fetch :static_shares}/config/initializers/secret_token.admin.rb #{fetch :release_path}/config/initializers/secret_token.rb"
      within "#{fetch :release_path}" do
        execute :rm, "-Rf #{fetch :release_path}/public"
        execute :ln, "-s #{fetch :static_shares}/public #{fetch :release_path}/public"

        execute :rm, "-Rf #{fetch :release_path}/log"
        execute :ln, "-s #{fetch :shared_path}/log #{fetch :release_path}/log"

        execute :rm, "-Rf #{fetch :release_path}/tmp"
        execute :ln, "-s #{fetch :shared_path}/tmp #{fetch :release_path}/tmp"

        execute :rm, "-Rf #{fetch :release_path}/app/models"
        execute :ln, "-s #{fetch :models_path} #{fetch :release_path}/app/models"
        
      end      
    end
  end

  desc "bundle_install"
  task :bundle_install do
    on roles(:app) do |host|
      within "#{fetch :deploy_to}/current" do
        execute :bundle, "install"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Compile Assets'
  task :compile_assets do
    on roles(:app) do |host|
      within "#{fetch :release_path}" do
        execute :bundle, "exec rake assets:precompile"
      end
    end
  end

  after :published, :update_submodule do

    Rake::Task["deploy:create_symlink"].invoke
    Rake::Task["deploy:bundle_install"].invoke
    Rake::Task["deploy:compile_assets"].invoke
    Rake::Task["deploy:restart"].invoke
    
    #deploy.bundle_install
    #deploy.restart
  end

  after :restart, :clear_cache do
    on roles(:app), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
