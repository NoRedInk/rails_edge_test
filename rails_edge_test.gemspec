# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_edge_test/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_edge_test'
  spec.version       = RailsEdgeTest::VERSION
  spec.authors       = ['Joshua Leven', 'Ju Liu']
  spec.email         = ['josh@noredink.com']

  spec.summary       = 'Generate json for front-end testing using your rails backend.'
  spec.description   = 'Keep your backend and front-end specs in sync! The rails_edge_test gem provides a dsl and rake task that uses your Rails app to generate json and appropriate wrapper files for use in your front-end testing.'
  spec.homepage      = 'https://github.com/NoRedInk/rails_edge_test'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables << 'generate_edges'
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 5.2.0', '< 7.1.0'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
