Capistrano::Configuration.instance.load do

  namespace :qd do

    namespace :scripts do

      def apt_install(*pkgs)
        run "apt-get -y install #{pkgs.join(" ")}"
      end

      def replace_in_file(find_exp, rep_exp, file)
        bn = file.split('/').last
        run "cp -n #{file} ~/#{bn}.old"
        run "sed -i 's/#{find_exp}/#{rep_exp}/g' #{file}"
      end

      task :standard_root_box_setup do
        #qd.scripts.ssh.copy_key
        qd.scripts.utils.update_package_manager
        qd.scripts.ssh.disable_passwords
        qd.scripts.utils.set_timezone_utc
        qd.scripts.utils.setup_deploy_user
        qd.scripts.git.install
      end

      namespace :git do

        task :install do
          apt_install "git-core"
        end

      end

      namespace :nginx do

        task :install do
          apt_install "nginx"
        end

        task :configure do
          replace_in_file("# server_names_hash_bucket_size [0-9]\\+", "server_names_hash_bucket_size 64", "/etc/nginx/nginx.conf")
        end

        task :configure_unicorn do
          rap = "/etc/nginx/sites-available/#{application}"
          rep = "/etc/nginx/sites-enabled/#{application}"

          # build and copy template
          copy_template_file("nginx/unicorn-site.conf.erb", rap)

          # link in sites-enabled
          run "ln -sf #{rap} #{rep}"
          qd.scripts.nginx.restart
        end

        task :restart do
          run "service nginx restart"
        end

      end

      namespace :unicorn do

        task :setup do
          dest = "#{app_dir_shared_path}/conf/unicorn.rb"
          copy_template_file("unicorn/unicorn-local.rb.erb", dest)
        end

      end

      namespace :ruby do

        task :install_rvm do
          set :rvm_install_with_sudo, true
          rvm.install_rvm
          rvm.install_ruby
        end

      end

      namespace :imagemagick do

        task :install do
          apt_install "imagemagick", "libmagickcore-dev", "libmagickwand-dev"
        end

      end

      namespace :ssh do

        task :copy_key do
          run_locally "ssh-copy-id #{user}@#{get_host}"
        end

        task :copy_key_to_root do
          set :user, 'root'
          set :default_shell, :bash
          run_locally "ssh-copy-id #{user}@#{get_host}"
        end

        task :disable_passwords do
          run "cp /etc/ssh/sshd_config ~/sshd_config.old"
          run "sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config"
        end

      end

      namespace :utils do

        task :df do
          run "df -h"
        end

        task :set_timezone_utc do
          run <<-END
            tz="`cat /etc/timezone`";
            if [ "$tz" != "Etc/UTC" ]; then
              echo "Setting timezone to UTC.";
              echo "Etc/UTC" > /etc/timezone;
              dpkg-reconfigure -f noninteractive tzdata;
            else
              echo "Timezone already set!";
            fi;
          END
        end

        task :setup_deploy_user do
          run <<-END
            if [ -z "$(getent passwd #{deploy_user})" ]; then
              echo "User #{deploy_user} doesn't exist. Creating.";
              useradd #{deploy_user} -m -s /bin/bash;
              # copy over keys
              mkdir ~#{deploy_user}/.ssh;
              cp /root/.ssh/authorized_keys ~#{deploy_user}/.ssh/;
              chown #{deploy_user} ~#{deploy_user}/.ssh/authorized_keys;
            else
              echo "User already exists.";
            fi;
          END
        end

        task :update_package_manager do
          run "apt-get update"
        end

      end

      namespace :extras do

        task :add_common_app_packages do
          qd.scripts.imagemagick.install
          apt_install "vim"
        end

      end

    end

  end

end


