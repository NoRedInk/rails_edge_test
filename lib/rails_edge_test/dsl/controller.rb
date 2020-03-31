module RailsEdgeTest::Dsl
  Controller = Struct.new(:controller_class) do
    def initialize(*args)
      super
      @actions = []
      @let_handler = LetHandler.new
    end

    def action(name, &block)
      new_action = Action.new(name, self)
      new_action.instance_exec(&block)
      @actions << new_action
    end

    def let(title, &block)
      @let_handler.add_definition(title, &block)
    end

    def __actions
      @actions
    end

    def __let_handler
      @let_handler
    end
  end
end
