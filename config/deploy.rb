# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'vue-music'
set :repo_url, 'git@github.com:xiajian/vue-music.git'

set :branch, fetch(:stage)
set :deploy_to, "/www/atyun/apps/vue-music/#{fetch(:branch)}/#{fetch(:stage)}"
set :user, 'atyun'
set :scm, :git
set :format, :pretty
set :log_level, :debug
set :pty, true
set :nvm_custom_path, '/home/atyun/.nvm'
set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v6.3.1'
set :nvm_map_bins, %w{node npm}

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'node_modules')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

set :keep_releases, 5

# set :npm_target_path, -> { release_path.join('subdir') } # default not set
set :npm_flags, '--production --silent --no-progress'    # default
set :npm_roles, :all                                     # default
set :npm_env_variables, {}                               # default_env

puts "stage: #{fetch(:stage)}"

namespace :deploy do

  # deploy 部署 
  before 'check:linked_files', 'shared:execute' do
    on roles(:all) do
      repo_path = "/www/atyun/apps/kawa/repo"
      
      unless test("[ -d #{fetch(:deploy_to)} ]")
        execute "source ~/.bash_profile; cd /www/atyun/apps/kawa/; mkdir -p #{fetch(:branch)}/#{fetch(:stage)}"
      end
      
      if test("[ -d #{repo_path} ]")
        execute "source ~/.bash_profile; cd #{repo_path}; git pull"
      else
        # FileUtils.mkdir_p repo_path
        execute "source ~/.bash_profile; mkdir -p #{repo_path}"
        
        execute "source ~/.bash_profile; cd /www/atyun/apps/kawa; git clone #{fetch(:repo_url)} repo"
      end
    end
  end
  
  after 'deploy:finished', 'webpack' do
    on roles(:all) do
       execute "cd /www/atyun/apps/vue-music/#{fetch(:branch)}/#{fetch(:stage)}/current; npm install; npm run deploy"
     end
  end
  
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end