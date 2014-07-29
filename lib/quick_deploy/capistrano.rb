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
    set(:app_dir_shared_path) { "#{app_dir}/shared" }
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
    set :rvm_type, :user

  end

  after 'multistage:ensure' do
    qd.load_nodes
  end

  # Helper methods
  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end
  # run a command on the server with a different user
  def ensure_user(new_user, &block)
    return if new_user == user
    old_user = user
    change_user(new_user)
    begin
      yield
    rescue Exception => e
      change_user(old_user)
      raise e
    end
    change_user(old_user)
  end
 
  # change the capistrano user
  def change_user(user)
    puts "=== CHANGING USER TO: #{user}".green
    set :user, user
    close_sessions
  end
   
  # disconnect all sessions
  def close_sessions
    sessions.values.each { |session| session.close }
    sessions.clear
  end

  Dir[File.join(File.dirname(__FILE__), 'capistrano/*.rb')].each do |qd_lib|
    load(qd_lib)
  end
  Dir[File.join(Dir.pwd, 'config/deploy/manifests/*.rb')].each do |qd_lib|
    load(qd_lib)
  end
  
end
