module RailsEdgeTest
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/rails_edge_test.rake'
    end
  end
end
