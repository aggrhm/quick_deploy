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

      #on :load, "qd:deploy:init"

      task :init do
        _cset :root, "#{deploy_to}/current/public"
        _cset :app_server, :unicorn

        ## App settings
        
        _cset(:app_name) { abort("Please specify application name") }
        _cset(:deploy_env) { abort("Please specify deployment stage") }
        _cset :user, 'login'
        _cset :www_dir, '/var/www'

        set(:application) { "#{app_name}-#{deploy_env}" }
        set(:rails_env) { deploy_env }
        _cset(:app_dir) { "#{www_dir}/#{application}" }
        _cset :deploy_via, 'remote_cache'
        _cset :use_sudo, false
        set(:deploy_to) { app_dir }

        ## SCM settings

        _cset(:repository) { abort("Specify the location of the repository") }
        _cset :branch, 'master'

        _cset :scm, :git
        _cset :scm_verbose, true

        default_run_options[:pty] = true
        default_run_options[:shell] = false
        ssh_options[:forward_agent] = true
        set :rvm_type, :system
        set :rvm_path, "/usr/local/rvm"
        

      end

    end

  end

end
