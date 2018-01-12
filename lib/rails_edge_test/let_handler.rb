module RailsEdgeTest
  class LetHandler
    attr_reader :let_blocks

    def initialize
      @let_blocks = {}
    end

    def add_definition(title, &block)
      @let_blocks[title] = block
    end

    def execute(title)
      block = @let_blocks[title]
      unless block
        fail NoMethodError, "no method or let block defined with name #{title}"
      end

      block.call
    end
  end
end
