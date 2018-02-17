module RailsEdgeTest::Printers
  class Tree
    def initialize
      @count = 0
    end

    def begin_suite
      puts ""
      puts "Generating Edges..."
      puts "-------------------"
      puts ""
    end

    def end_suite
      puts "\n#{@count} edge specs executed."
    end

    def begin_controller(controller)
      puts controller.controller_class.name
    end

    def end_controller
      puts ""
    end

    def begin_action(action)
      puts "  #{action.name}"
    end

    def end_action
    end

    def begin_edge(edge)
      print "    #{edge.description}"
    end

    def end_edge
      puts " ... done"
      @count += 1
    end
  end
end
