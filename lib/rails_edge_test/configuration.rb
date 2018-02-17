module RailsEdgeTest
  class Configuration
    attr_accessor :elm_path, :edge_root_path

    def initialize
      self.elm_path = Rails.root.join('spec')
      self.edge_root_path = Rails.root.join('spec', 'edge')
    end

    # Provide any Module here with methods you would like to be able to
    # access from within an `edge` block.
    # @param [Module] mod - a module to be included into all `edge` blocks
    def include(mod)
      Edge.include mod
    end
  end
end
