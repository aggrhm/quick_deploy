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

First you need to specify manifests for how to bootstrap machines:

1. Add manifests for servers

		# config/deploy/manifests/app.rb
		run_script 'copy_ssh_key'		# will pull key location from options
		run_script 'disable_password_ssh'
		run_script 'setup_deploy_user'
		run_script 'set_timezone_utc'
		run_script 'install_rvm'
		run_script 'install_nginx'
		run_script 'setup_nginx_unicorn'
		run_script 'prepare_www_dir'
		run_script 'install_standard_app_packages'
		run_script 'install_custom_app_packages'	# we will add later

2. Add custom scripts

		# config/deploy/scripts/packages.rb
		register_script 'install_additional_packages' do
			apt-get install <mypackage>
		end

To deploy do the following:

1. First create a new instance

		$ cap [staging|production] qd:node:create
			# prompt for tag (e.g. 'app-01')
			# tag contains role and id

2. Bootrap the instance

		$ cap [staging|production] qd:bootstrap
			# prompt for tag

3. Deploy to instance

		$ cap [staging|production] deploy

4. Later... bring down instance

		$ cap [staging|production] qd:node:destroy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
