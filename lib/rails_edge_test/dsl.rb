module RailsEdgeTest
  module Dsl
    def controller(controller_class, &block)
      controller = RailsEdgeTest::Controller.new(controller_class)
      controller.instance_exec(&block)
      Dsl.add(controller)
    end

    class << self
      def reset!
        @controllers = []
      end

      def execute!
        count = 0

        RailsEdgeTest.configuration.wrap_suite_execution do

          @controllers.each do |controller|
            controller.__actions.each do |action|
              action.__edges.each do |edge, block|

                RailsEdgeTest.configuration.wrap_edge_execution do
                  define_lets(edge, action.__lets_handler)
                  edge.instance_exec(&block)
                  count += 1
                end

              end
            end
          end

        end

        count
      end

      def add(controller)
        @controllers << controller
      end

      private
      def define_lets(edge, lets_handler)
        lets_handler.let_blocks.each do |title, block|
          edge.define_singleton_method(title) do
            @let_cache[title] ||= instance_eval(&block)
          end
        end
      end
    end
  end
end
