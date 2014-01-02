# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beam/version'

Gem::Specification.new do |spec|
  spec.name           = "beam"
  spec.version        = Beam::VERSION
  spec.authors        = ["Gourav Tiwari"]
  spec.email          = ["gouravtiwari21@gmail.com"]
  spec.homepage       = "https://github.com/gouravtiwari/beam"
  spec.summary        = "CSV uploader library for fast and easy upload"
  spec.description    = "CSV uploader library for fast and easy upload for Rails applications"
  spec.license        = "MIT"

  spec.files          = `git ls-files`.split($/)
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "activerecord-import", '0.4.0'

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "spork", '~>1.0rc'
  spec.add_development_dependency "guard-spork"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "rb-fsevent"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "debugger"
  spec.add_development_dependency "coveralls"
end
