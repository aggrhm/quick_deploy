Capistrano::Configuration.instance.load do

  namespace :qd do

    namespace :node do

      _cset :cloud_provider, 'manual'

      before "qd:node:create" do
        #prepare_local_role
      end

      task :create, :roles => :local do
        opts = {}
        opts[:roles] = get_env("NODE_ROLES", "Enter the roles for this node", true, "app").split(/[,\s]/)
        opts[:name] = get_env("NODE_NAME", "Enter the name of this node", true)
        opts[:ip_address] = get_env("IP_ADDR", "Enter the ip address of this node", true) if cloud_provider == 'manual'
        QuickDeploy.create_instance(variables, opts)
      end
      after "qd:node:create", "qd:node:setup"

      task :setup do
        # TODO : store node information

      end

    end

  end
end
