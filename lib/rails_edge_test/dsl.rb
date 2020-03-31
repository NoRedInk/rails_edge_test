module RailsEdgeTest
  module Dsl
    def controller(controller_class, &block)
      controller = RailsEdgeTest::Dsl::Controller.new(controller_class)
      controller.instance_exec(&block)
      Dsl.add(controller)
    end

    class << self
      def reset!
        @controllers = []
      end

      def execute!
        printer = RailsEdgeTest.configuration.printer.new
        printer.begin_suite

        RailsEdgeTest.configuration.wrap_suite_execution do

          @controllers.each do |controller|
            printer.begin_controller(controller)

            controller.__actions.each do |action|
              printer.begin_action(action)

              action.__edges.each do |edge, block|
                printer.begin_edge(edge)

                RailsEdgeTest.configuration.wrap_edge_execution do
                  define_lets(edge, controller.__let_handler)
                  define_lets(edge, action.__let_handler)
                  edge.instance_exec(&block)
                end

                printer.end_edge
              end

              printer.end_action
            end

            printer.end_controller
          end

        end
        printer.end_suite
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
