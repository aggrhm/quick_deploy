Capistrano::Configuration.instance.load do

  namespace :qd do

      def get_server_conf
        str = capture("cat /etc/quick_deploy.conf")
        str.split("\n").reduce({}) {|hash, line|
          key,val = line.split('=')
          hash[key] = val
          hash
        }
      end

      def get_server_tag
        @conf ||= get_server_conf
        @conf["TAG"]
      end

      def get_host
        capture("echo $CAPISTRANO:HOST$").strip
      end

      def parse_role(tag)
        tag.split('-')[0]
      end

      def get_server_role
        parse_role(get_server_tag)
      end

    namespace :core do

      task :print_tag do
        run "cat /etc/quick_deploy.conf"
      end

    end

  end

end

