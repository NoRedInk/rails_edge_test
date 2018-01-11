module RailsEdgeTest
  Edge = Struct.new(:description, :name, :controller_class) do
    def controller
      @controller ||= controller_class.new
    end
  end
end
