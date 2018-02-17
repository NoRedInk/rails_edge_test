module RailsEdgeTest::Dsl
  Action = Struct.new(:name, :controller_class) do
    def initialize(*args)
      super
      @edges = {}
      @lets_handler = LetHandler.new
    end

    def edge(description, &block)
      edge = Edge.new(description, name, controller_class)
      @edges[edge] = block
    end

    def let(title, &block)
      @lets_handler.add_definition(title, &block)
    end

    def generate(title, &block)
      @lets_handler.add_definition("generate_#{title}", &block)
    end

    def __edges
      @edges
    end

    def __lets_handler
      @lets_handler
    end
  end
end
