require "rails_edge_test/version"
require "rails_edge_test/dsl"
require "rails_edge_test/dsl/controller"
require "rails_edge_test/dsl/action"
require "rails_edge_test/dsl/edge"
require "rails_edge_test/dsl/let_handler"
require "rails_edge_test/configuration"
require "rails_edge_test/printers/boring"
require "rails_edge_test/printers/silent"
require "rails_edge_test/printers/tree"

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
# - Flesh out the README
# - Refactor LetHelper to define a Module, and include it when necessary
