Capistrano::Configuration.instance.load do

  namespace :qd do

      QuickDeploy.initialize(root: Dir.pwd)

      task :load_nodes do
        puts "\t>> Loading node list".yellow
        if cloud_provider == "boxchief"
          set :nodes, QuickDeploy.load_node_db_from_boxchief(deploy_env, boxchief_app_token)
        else
          set :nodes, QuickDeploy.load_node_db(deploy_env)
        end
        puts "\t>> #{nodes.length} nodes found.".green

        # handle filter
        if ENV["NODES"]
          selected_nodes = ENV["NODES"].split(',')
          nodes.select! {|node| selected_nodes.include? node[:name]}
          puts "\t>> Filtered to #{nodes.length} nodes.".yellow
        end

        nodes.each do |node|
          puts "\t - Registering #{node[:ip_address]}(#{node[:name]}) as #{node[:roles].join(",")}.".green
          server node[:ip_address], *node[:roles].collect{|role| role.to_sym}
        end
      end
      

      def get_node_conf
        str = capture("cat /etc/quick_deploy.conf")
        str.split("\n").reduce({}) {|hash, line|
          key,val = line.split('=')
          hash[key] = val
          hash
        }
      end

      def get_host
        capture("echo $CAPISTRANO:HOST$").strip
      end

      def get_host_profile(host_id)
        nodes.select{|prof| prof[:name] == host_id || prof[:ip_address] == host_id}.first
      end

      def get_binding
        binding
      end

      def copy_template_file(name, remote_path, dest=:remote)
        # TODO: first look in local dir for template
        # next look in gem templates for file
        tf = File.join(QuickDeploy::TEMPLATES_DIR, name)
        if File.exists?(tf)
          puts ">> Copying template #{tf} to #{remote_path}.".green
          res = ERB.new(File.read(tf)).result(get_binding)
          if dest == :remote
            put(res, remote_path)
          else
            File.open(remote_path, 'w') {|f| f.write(res)}
          end
        else
          puts ">> Couldn't not find template #{tf}".red
        end
      end

      def get_env(name, desc, required=false, default=nil)
        value = ENV.delete(name)
        msg = "#{desc}"
        msg << " [#{default}]" if default
        msg << ": "
        value = Capistrano::CLI.ui.ask(msg) unless value
        value = value.size == 0 ? default : value
        fatal "#{name} is required, pass using environment or enter at prompt" if required && ! value

        # Explicitly convert to a String to avoid weird serialization issues with Psych.
        value.to_s
      end

      def prepare_local_role
        server 'localhost', :local
      end
      

    namespace :core do


      task :print_tag do
        run "cat /etc/quick_deploy.conf"
      end

    end

  end

end

