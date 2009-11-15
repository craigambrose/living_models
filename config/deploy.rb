set :stages, %w(production)
set :default_stage, "production"

require 'capistrano/ext/multistage'

set :application, "living_models"
set :repository,  "git@github.com:craigambrose/living_models.git"
set :scm, "git"
set :branch, "master" unless exists?(:branch)

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

after "deploy:update_code" do
  link_from_shared_to_current('config')
end

def link_from_shared_to_current(path, dest_path = path)
  src_path = "#{shared_path}/#{path}"
  dst_path = "#{release_path}/#{dest_path}"
  run "for f in `ls #{src_path}/` ; do ln -nsf #{src_path}/$f #{dst_path}/$f ; done"
end