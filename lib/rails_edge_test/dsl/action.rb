# frozen_string_literal: true

module RailsEdgeTest
  module Dsl
    Action = Struct.new(:name, :controller) do
      def initialize(*args)
        super
        @edges = {}
        @let_handler = LetHandler.new
      end

      def edge(description, &block)
        edge = Edge.new(description, self)
        @edges[edge] = block
      end

      def let(title, &block)
        @let_handler.add_definition(title, &block)
      end

      def generate(title, &block)
        @let_handler.add_definition("generate_#{title}", &block)
      end

      def __edges
        @edges
      end

      def __let_handler
        @let_handler
      end

      def controller_class
        controller.controller_class
      end

      # support calling methods defined in controller
      def method_missing(method_name, ...)
        if controller.respond_to?(method_name)
          controller.public_send(method_name, ...)
        else
          super
        end
      end

      # always define respond_to_missing? when defining method_missing:
      # https://thoughtbot.com/blog/always-define-respond-to-missing-when-overriding
      def respond_to_missing?(method_name, include_private = false)
        controller.respond_to?(method_name) || super
      end
    end
  end
end
