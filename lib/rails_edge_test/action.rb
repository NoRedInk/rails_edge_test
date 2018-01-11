module RailsEdgeTest
  Action = Struct.new(:name, :controller_class) do
    def initialize(*args)
      super
      @edges = {}
    end

    def __edges
      @edges
    end

    def edge(description, &block)
      edge = RailsEdgeTest::Edge.new(description, name, controller_class)
      @edges[edge] = block
    end
  end
end
