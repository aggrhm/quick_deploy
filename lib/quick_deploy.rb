require "quick_deploy/version"
require "digital_ocean"
require "yaml"

module QuickDeploy

  TEMPLATES_DIR = File.expand_path("../templates", File.dirname(__FILE__))

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

  # should only return once we know IP address or there is an error
  def self.create_instance(vars, opts)
    puts ">> Creating #{vars[:cloud_provider]} node...".green 

    case vars[:cloud_provider].to_sym
    when :manual
    when :digital_ocean
      api = DigitalOcean::API.new({
        client_id: vars[:digital_ocean_client_id],
        api_key: vars[:digital_ocean_api_key]
      })
      resp = api.droplets.create({
        :name => opts[:name],
        :size_id => 66,
        :image_id => 284203,
        :region_id => 1
      })

      return nil unless resp.status == "OK"
      did = resp.droplet.id

      # poll for ip address
      begin
        puts "\tChecking node...".yellow
        resp = api.droplets.show(did)
        sleep 2
      end until (resp.status == "OK" && !resp.droplet.ip_address.nil?)

      ip_addr = resp.droplet.ip_address
      puts ">> Node registered with IP #{ip_addr}.".green

      opts[:id] = resp.droplet.id
      opts[:ip_address] = resp.droplet.ip_address
    end

    opts[:app_name] = vars[:app_name]
    opts[:deploy_env] = vars[:deploy_env]
    opts[:cloud_provider] = vars[:cloud_provider]
    self.register_node(opts)

    return opts
  end

  def self.destroy_instance(vars, node_name)
    puts "Deleting node #{node_name}...".green
    prof = self.get_node_profile(node_name)
    return false if prof.nil?

    case prof[:cloud_provider].to_sym
    when :manual
    when :digital_ocean
      api = DigitalOcean::API.new({
        client_id: vars[:digital_ocean_client_id],
        api_key: vars[:digital_ocean_api_key]
      })
      resp = api.droplets.delete(prof[:id])

      return false unless resp.status == "OK"
    end

    self.unregister_node(node_name)
    return true
    

  end

  # store to local database in app (./config/manifests/nodes.yml)
  def self.register_node(opts)
    db = self.load_node_db
    db << opts
    self.write_node_db(db)
    puts ">> Node saved to registry.".green
  end

  def self.unregister_node(node_name)
    db = self.load_node_db
    db.delete_if {|node| node[:name] == node_name}
    self.write_node_db(db)
    puts ">> Node removed from registry.".green
  end

  def self.node_db_path
    db_path = File.join(self.root, "config/deploy/manifests/nodes.yml")
  end

  def self.load_node_db
    db_path = self.node_db_path
    if File.exists?(db_path)
      db = YAML::load_file(db_path)
    else
      db = []
      self.write_node_db(db)
    end
    return db
  end

  def self.write_node_db(db)
    File.open(self.node_db_path, "w") do |f|
      f.write(db.to_yaml)
    end
  end

  def self.get_node_profile(id)
    #parse_role(get_node_tag)
    db = self.load_node_db
    db.select{|prof| prof[:name] == id || prof[:ip_address] == id}.first
  end

  def self.get_node_roles(name)
    prof = self.get_node_profile(name)
    prof ? prof[:roles] : []
  end

end
