module RailsEdgeTest
  class Configuration
    attr_accessor :elm_path, :edge_root_path

    def initialize
      self.elm_path = Rails.root.join('spec')
      self.edge_root_path = Rails.root.join('spec', 'edge')
    end
  end
end
