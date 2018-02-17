# Use the :generate_files task in order to generate JSON files for front-end testing.
# It will execute the files in the directory (and subdirs) specified by
# RailsEdgeTest.configure { |config| config.edge_root_path = 'path/to/edge/files' }
namespace :rails_edge_test do
  desc "run all _edge.rb files in your specified edge directory"
  task :generate_files => :environment do
    unless Rails.env.test?
      puts "ERROR: Attempt to run in #{Rails.env} environment failed. Must be run in test environment."
      exit
    end

    RailsEdgeTest::Dsl.reset!

    glob = File.join(
      RailsEdgeTest.configuration.edge_root_path,
      '**/*_edge.rb'
    )

    Dir.glob(glob).each do |file|
      load file
    end

    RailsEdgeTest::Dsl.execute!
  end
end
