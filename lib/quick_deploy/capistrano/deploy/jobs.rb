Capistrano::Configuration.instance.load do

  namespace :qd do
    namespace :jobs do

      desc "Restart job processes"
      task :restart, :roles => :app, :except => {:no_release => true} do
        job_scripts.each do |script|
          run "cd #{current_path} && bundle exec script/#{script} -e #{deploy_env} restart"
        end
      end

    end
  end

  #after "deploy:restart", "qd:jobs:restart"

end
