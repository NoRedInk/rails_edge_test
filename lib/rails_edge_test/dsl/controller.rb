module RailsEdgeTest::Dsl
  Controller = Struct.new(:controller_class) do
    def initialize(*args)
      super
      @actions = []
    end

    def __actions
      @actions
    end

    def action(name, &block)
      ret_action = Action.new(name, controller_class)
      ret_action.instance_exec(&block)
      @actions << ret_action
    end
  end
end
