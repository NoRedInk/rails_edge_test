# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_edge_test/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_edge_test"
  spec.version       = RailsEdgeTest::VERSION
  spec.authors       = ["Joshua Leven"]
  spec.email         = ["josh@noredink.com"]

  spec.summary       = %q{Generate json for front-end testing using your rails backend.}
  spec.description   = %q{Keep your backend and front-end specs in sync! The rails_edge_test gem provides a dsl and rake task that uses your Rails app to generate json and appropriate wrapper files for use in your front-end testing.}
  spec.homepage      = "https://github.com/NoRedInk/rails_edge_test"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
