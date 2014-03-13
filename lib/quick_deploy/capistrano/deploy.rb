Capistrano::Configuration.instance.load do

  Dir[File.join(File.dirname(__FILE__), 'deploy/*.rb')].each do |qd_lib|
    load(qd_lib)
  end


  namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      case app_server
      when :unicorn
        qd.unicorn.restart
      end
    end
  end

  namespace :qd do
    namespace :deploy do
      task :setup, :roles => :app do
        set :default_shell, :bash

        # setup based on server
        case app_server
        when :unicorn
          qd.unicorn.setup
        end

      end

    end
  end

  after "deploy:setup", "qd:deploy:setup"

end
