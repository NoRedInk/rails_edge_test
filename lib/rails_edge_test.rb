require "rails_edge_test/version"
require "rails_edge_test/dsl"
require "rails_edge_test/controller"
require "rails_edge_test/action"
require "rails_edge_test/edge"
require "rails_edge_test/let_handler"
require "rails_edge_test/configuration"
require "rails_edge_test/railtie"

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
# - DatabaseCleaner + configuration
# - Factory[Girl/Bot] + configuration
# - Flesh out the README
# - Refactor LetHelper to define a Module, and include it when necessary
