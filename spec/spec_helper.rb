# frozen_string_literal: true

require 'bundler/setup'
require 'rails_edge_test'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    RailsEdgeTest.configure do |ret_config|
      ret_config.printer = RailsEdgeTest::Printers::Silent
    end
  end
end
