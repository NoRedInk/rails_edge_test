include RailsEdgeTest::Dsl

controller ApplicationController do
  action :home do
    edge "write elm file" do
      perform_get
      produce_elm_file('Home')
    end
  end
end
