require "rvm/capistrano"

Capistrano::Configuration.instance.load do

  Dir[File.join(File.dirname(__FILE__), 'capistrano/*.rb')].each do |qd_lib|
    load(qd_lib)
  end
  Dir[File.join(Dir.pwd, 'config/deploy/manifests/*.rb')].each do |qd_lib|
    load(qd_lib)
  end
  
end
