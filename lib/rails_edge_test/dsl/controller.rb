module RailsEdgeTest::Dsl
  Controller = Struct.new(:controller_class) do
    def initialize(*args)
      super
      @actions = []
    end

    def action(name, &block)
      new_action = Action.new(name, controller_class)
      new_action.instance_exec(&block)
      @actions << new_action
    end

    def __actions
      @actions
    end
  end
end
