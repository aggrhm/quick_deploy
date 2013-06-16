Capistrano::Configuration.instance.load do

  namespace :qd do

      puts ">> Loading node list".yellow
      QuickDeploy.initialize(root: Dir.pwd)
      set :nodes, QuickDeploy.load_node_db
      puts ">> #{nodes.length} nodes found.".green
      nodes.each {|node| server(node[:ip_address], *node[:roles].collect{|role| role.to_sym}) }
      

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

      def get_binding
        binding
      end

      def copy_template_file(name, remote_path)
        # TODO: first look in local dir for template
        # next look in gem templates for file
        tf = File.join(QuickDeploy::TEMPLATES_DIR, name)
        if File.exists?(tf)
          puts ">> Copying template #{tf} to #{remote_path}.".green
          res = ERB.new(File.read(tf)).result(get_binding)
          put(res, remote_path)
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

