# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quick_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "quick_deploy"
  spec.version       = QuickDeploy::VERSION
  spec.authors       = ["Alan Graham"]
  spec.email         = ["alan@productlab.com"]
  spec.description   = %q{A library for deploying applications to the cloud.}
  spec.summary       = %q{A library for deploying applications to the cloud.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "capistrano", '~> 2.15'
  spec.add_dependency "rvm-capistrano"
  spec.add_dependency "colored"
  spec.add_dependency "digital_ocean"
  spec.add_dependency "faraday"
end
