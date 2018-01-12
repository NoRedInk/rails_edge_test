module RailsEdgeTest
  class Configuration
    attr_accessor :elm_path

    def initialize
      self.elm_path = Rails.root.join('spec')
    end
  end
end
