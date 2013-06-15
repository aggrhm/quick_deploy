require "quick_deploy/version"

module QuickDeploy
  # Your code goes here...
  def self.initialize(opts)
    @@root = opts[:root]
  end

  def self.root
    @@root
  end

  if defined?(Rails::Railtie)

    class Railtie < Rails::Railtie

      config.before_configuration do
        QuickDeploy::initialize({root: Rails.root, env: Rails.env})
      end

    end

  end
end
