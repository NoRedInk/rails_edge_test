require 'rails_helper'

RSpec.describe "rake rails_edge_test:generate_files" do
  let(:elm_path) { Rails.root.join('tmp') }
  let(:expected_filepath) { File.join(elm_path, 'Edge/ApplicationController/Home.elm') }

  before(:all) do
    require "rake"
    Rails.application.load_tasks
  end

  before do
    RailsEdgeTest.configure do |config|
      config.edge_root_path = Rails.root.join('edge')
      config.elm_path = elm_path
    end

    # ensure the elm_path directory always starts empty
    begin
      FileUtils.remove_entry_secure(File.join(elm_path, 'Edge'))
    rescue Errno::ENOENT
    end
  end


  it "creates a file with the expected contents" do
    expect(File.exists? expected_filepath).to be false

    Rake::Task['rails_edge_test:generate_files'].invoke

    expect(File.exists? expected_filepath).to be true
    elm = File.open(expected_filepath, 'r').read(nil)
    expect(elm).to eq(<<~ELM)
      module Edge.ApplicationController.Home exposing (json)


      json : String
      json =
          """
      {"example":"data"}
          """
    ELM
  end
end
