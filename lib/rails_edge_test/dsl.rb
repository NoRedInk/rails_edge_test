module RailsEdgeTest
  module Dsl
    def controller(controller_class, &block)
      controller = RailsEdgeTest::Controller.new(controller_class)
      controller.instance_exec(&block)
      Dsl.add(controller)
    end

    def self.reset!
      @controllers = []
    end

    def self.execute!
      @controllers.each do |controller|
        controller.__actions.each do |action|
          action.__edges.each do |edge, block|
            edge.__define_lets(action.__lets_handler)
            edge.instance_exec(&block)
          end
        end
      end
    end

    def self.add(controller)
      @controllers << controller
    end
  end
end
