Capistrano::Configuration.instance.load do

  namespace :qd do

    namespace :bootstrap do

      task :default do
        qd.bootstrap.apply
      end

      task :apply do
        set :user, 'root'
        set :default_shell, :bash

        host = get_host
        prof = QuickDeploy.get_node_profile(host)
        roles = prof ? prof[:roles] : []
        puts ">> Bootstrapping #{host}(#{prof[:name]}) for #{roles.join(",")}...".yellow
        roles.each do |role|
          task_n = "apply_#{role.to_s}_manifest"
          if qd.bootstrap.respond_to?(task_n)
            puts ">> Found manifest for #{role}".green
            qd.bootstrap.send(task_n)
          end
        end
      end

      #after "qd:bootstrap:apply", "deploy:setup"

    end

  end

end
