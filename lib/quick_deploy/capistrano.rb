require "rvm/capistrano"
require "erb"
require "colored"
require "quick_deploy"

Capistrano::Configuration.instance.load do

  on :load do
    _cset (:root) {"#{deploy_to}/current/public"}
    _cset :app_server, :unicorn

    ## App settings
    
    _cset(:app_name) { abort("Please specify application name") }
    _cset(:deploy_env) { abort("Please specify deployment stage") }
    _cset(:deploy_user) { abort("Please specify deploy user") }
    _cset(:user) { deploy_user }
    _cset(:www_dir) { "/home/#{deploy_user}" }

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
  end

  # Helper methods
  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

  Dir[File.join(File.dirname(__FILE__), 'capistrano/*.rb')].each do |qd_lib|
    load(qd_lib)
  end
  Dir[File.join(Dir.pwd, 'config/deploy/manifests/*.rb')].each do |qd_lib|
    load(qd_lib)
  end
  
end
