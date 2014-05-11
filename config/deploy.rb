set :application, 'peddie_soundfile'
set :repo_url, 'https://github.com/jiehanzheng/peddie_soundfile.git'

set :deploy_to, '/home/webapp/peddie_soundfile'

set :linked_files, %w{config/database.yml config/secrets.yml config/initializers/omniauth.rb}
set :linked_dirs, %w{uploads bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rvm1_ruby_version, '2.0.0'

namespace :deploy do

  desc 'Upload secret configuration files'
  task :upload_config do
    on roles(:app), in: :sequence do
      upload! 'config/database.yml',             "#{shared_path}/config/database.yml"
      upload! 'config/secrets.yml',              "#{shared_path}/config/secrets.yml"
      upload! 'config/initializers/omniauth.rb', "#{shared_path}/config/initializers/omniauth.rb"
    end
  end

  before 'deploy:check:linked_dirs', :upload_config

end
