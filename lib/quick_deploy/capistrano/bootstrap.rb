Capistrano::Configuration.instance.load do

  namespace :qd do

    namespace :bootstrap do

      task :apply do
        set :user, 'root'
        set :default_shell, :bash

        role = get_server_role
        qd.bootstrap.send("apply_#{role}_manifest")
      end

    end

  end

end
