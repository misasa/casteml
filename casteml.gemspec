# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'casteml/version'

Gem::Specification.new do |spec|
  spec.name          = "casteml"
  spec.version       = Casteml::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = "Command-line utilities for CASTEML datasets"
  spec.description   = "Convert, join, split, and plot CASTEML datasets and transfer them to and from Medusa."
  spec.homepage      = "https://github.com/misasa/casteml"
  spec.license       = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = %w[LICENSE.txt README.md bin/casteml] +
                       Dir['lib/**/*.rb', 'config/alchemist/*.yml',
                           'remote_dump/MedusaRestClient/*.marshal', 'template/**/*.erb'].sort
  spec.executables   = ["casteml"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '>= 5.0', '< 9'
  spec.add_runtime_dependency 'alchemist', '~> 0.1.7'
  spec.add_runtime_dependency 'csv'
  spec.add_runtime_dependency 'erb'
  spec.add_runtime_dependency 'medusa_rest_client', '~> 1.5', '>= 1.5.4'
  spec.add_runtime_dependency 'rexml', '>= 3.2', '< 4'

  spec.add_development_dependency "bundler", ">= 2.4", "< 5"
  spec.add_development_dependency "rake", ">= 13.0", "< 14"
  spec.add_development_dependency "rspec", "~> 3.13"
end
