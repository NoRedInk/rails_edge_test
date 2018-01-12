require "rails_edge_test/version"
require "rails_edge_test/dsl"
require "rails_edge_test/controller"
require "rails_edge_test/action"
require "rails_edge_test/edge"
require "rails_edge_test/let_handler"
require "rails_edge_test/configuration"

module RailsEdgeTest
  module_function
  def configure(&block)
    block.call configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end
end

# TODO:
# - Rake task + Railtie + configuration
# - DatabaseCleaner + configuration
# - Factory[Girl/Bot] + configuration
