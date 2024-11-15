# frozen_string_literal: true

module RailsEdgeTest
  module Dsl
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
        raise NoMethodError, "no method or let block defined with name #{title}" unless block

        block.call
      end
    end
  end
end
