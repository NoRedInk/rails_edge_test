# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_edge_test/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_edge_test"
  spec.version       = RailsEdgeTest::VERSION
  spec.authors       = ["Joshua Leven", "Ju Liu"]
  spec.email         = ["josh@noredink.com"]

  spec.summary       = %q{Generate json for front-end testing using your rails backend.}
  spec.description   = %q{Keep your backend and front-end specs in sync! The rails_edge_test gem provides a dsl and rake task that uses your Rails app to generate json and appropriate wrapper files for use in your front-end testing.}
  spec.homepage      = "https://github.com/NoRedInk/rails_edge_test"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   << "generate_edges"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "actionpack", ">= 5.2.0", "< 7.0.0"

  spec.add_development_dependency "rails", ">= 5.2", "< 7.0.0"
  spec.add_development_dependency "sqlite3", "~> 1.4.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
end
