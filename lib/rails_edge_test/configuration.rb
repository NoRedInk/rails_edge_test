module RailsEdgeTest
  class Configuration
    attr_accessor :elm_path, :edge_root_path

    def initialize
      self.elm_path = Rails.root.join('spec')
      self.edge_root_path = Rails.root.join('spec', 'edge')
      @before_suite_blocks = []
      @before_each_blocks = []
      @after_each_blocks = []
    end

    # Provide any Module here with methods you would like to be able to
    # access from within an `edge` block.
    # @param [Module] mod - a module to be included into all `edge` blocks
    def include(mod)
      Dsl::Edge.include mod
    end

    # Provide a block to be executed once before running any `edge` blocks
    def before_suite(&block)
      @before_suite_blocks << block
    end

    # Provide a block to be executed before running each `edge` block
    def before_each(&block)
      @before_each_blocks << block
    end

    # Provide a block to be executed after running each `edge` block
    def after_each(&block)
      @after_each_blocks << block
    end

    def wrap_suite_execution(&block)
      @before_suite_blocks.each do |before_suit_block|
        before_suit_block.call
      end

      block.call
    end

    def wrap_edge_execution(&edge)
      @before_each_blocks.each do |before_each_block|
        before_each_block.call
      end

      edge.call

      @after_each_blocks.each do |after_each_block|
        after_each_block.call
      end
    end
  end
end
