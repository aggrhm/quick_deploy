# QuickDeploy

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'quick_deploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install quick_deploy

## Usage

The directory structure for deployment is as follows:

		config/

			deploy.rb				# standard setup, see below

			deploy/
				production.rb
				staging.rb
				manifests/		# how to build servers for each role
					app.rb
					mongo.rb
					ceph.rb
					redis.rb
					monitor.rb
					nodes.yml		# an inventory of your registered servers

				scripts/			# helper scripts for bootstrapping
				templates/		# erb templates for configuration files


### Deploy Configuration Files

		# config/deploy.rb
		require "rvm/capistrano"                  # Load RVM's capistrano plugin.
		require "bundler/capistrano"
		require "capistrano/ext/multistage"
		require "quick_deploy/capistrano"

		set :stages, %w{production}
		set :default_stage, "production"
		set :rvm_ruby_string, 'ruby-1.9.3-p125'  # Or whatever env you want it to run in.

		set :app_name, 'artisimo'
		set :repository,  "git@myrick.qstudiosonline.com:#{app_name}.git"
		set :www_dir, "/home/deploy"		# defaults to this, so really not necessary
		set :deploy_user, 'deploy'

		# config/deploy/production.rb
		set :domain, 'fiercecanvas.com'
		set :deploy_env, 'production'
		set :branch, 'master'
				

### Manifests

First you need to specify manifests for how to bootstrap machines:

1. Add manifests for servers

		# config/deploy/manifests/app.rb
		namespace :qd do
			namespace :bootstrap do
				qd.scripts.standard_root_box_setup		# will login as root and setup users, timezone, ssh, etc.
				qd.scripts.ruby.install_rvm						# installs ruby and the ruby version you declare with :rvm_ruby_string
				qd.scripts.extras.add_common_app_packages	# adds common packages for deploying apps (e.g. imagemagick)
				qd.scripts.nginx.install							# installs the package version of nginx
				qd.scripts.nginx.configure_unicorn		# prepares nginx to support our application
			end
		end

2. Add custom scripts

		# config/deploy/scripts/packages.rb
		namespace :qd do
			namespace :scripts do
				task :install_additional_packages do
					apt_install "my-package", "another-package"		# uses apt_install helper to answer yes to prompts
				end
		end


### Deployment

To deploy do the following:

1. First create a new instance

		$ cap [staging|production] qd:node:create
			# prompt for role (e.g. 'app')
			# prompt for server name

2. Bootrap the instance

		$ cap [staging|production] qd:bootstrap
			# prompt for name	(coming soon)

3. Deploy to instance

		$ cap [staging|production] deploy:setup
		$ cap [staging|production] deploy

4. Later... bring down instance

		$ cap [staging|production] qd:node:destroy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
