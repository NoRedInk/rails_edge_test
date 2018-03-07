module RailsEdgeTest
  module Runner
    module_function
    def go!(args = [])
      unless Rails.env.test?
        puts "Failure! Unable to set Rails environment to test."
        exit
      end

      RailsEdgeTest::Dsl.reset!

      glob_path = '**/*_edge.rb'

      if args.length > 0
        glob_path = args.shift
      end

      glob = File.join(
        RailsEdgeTest.configuration.edge_root_path,
        glob_path
      )

      Dir.glob(glob).each do |file|
        load file
      end

      RailsEdgeTest::Dsl.execute!
    end

    def load_rails_environment!(rails_root)
      ENV["RAILS_ENV"]="test"
      rails_app_path = File.join(rails_root, "config/application")
      require rails_app_path

      Rails.application.require_environment!

      require "rake"
      Rails.application.load_tasks
    end
  end
end
