require 'rails_helper'

RSpec.describe RailsEdgeTest::Runner do
  let(:elm_path) { Rails.root.join('tmp') }
  let(:expected_home_filepath) { File.join(elm_path, 'Edge/ApplicationController/Home.elm') }
  let(:expected_other_filepath) { File.join(elm_path, 'Edge/ApplicationController/Another.elm') }

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


  it "creates the files with the expected contents" do
    expect(File.exists? expected_home_filepath).to be false
    expect(File.exists? expected_other_filepath).to be false

    RailsEdgeTest::Runner.go!

    expect(File.exists? expected_home_filepath).to be true
    expect(File.exists? expected_other_filepath).to be true

    elm = File.open(expected_home_filepath, 'r').read(nil)
    expect(elm).to eq(<<~ELM)
      module Edge.ApplicationController.Home exposing (json)


      json : String
      json =
          """
      {
        "example": "data"
      }
          """
    ELM
  end

  it "only creates files that match the args" do
    expect(File.exists? expected_home_filepath).to be false
    expect(File.exists? expected_other_filepath).to be false

    # Provide filepath relative to edge_root_path
    RailsEdgeTest::Runner.go!(["spec/support/test_app/edge/another_edge.rb"])

    expect(File.exists? expected_home_filepath).to be false
    expect(File.exists? expected_other_filepath).to be true

    elm = File.open(expected_other_filepath, 'r').read(nil)
    expect(elm).to eq(<<~ELM)
      module Edge.ApplicationController.Another exposing (json)


      json : String
      json =
          """
      {
        "example": "data"
      }
          """
    ELM
  end

  it "allows full paths for creating files" do
    expect(File.exists? expected_home_filepath).to be false
    expect(File.exists? expected_other_filepath).to be false

    # Provide full filepath relative to root
    RailsEdgeTest::Runner.go!(["spec/support/test_app/edge/another_edge.rb"])

    expect(File.exists? expected_home_filepath).to be false
    expect(File.exists? expected_other_filepath).to be true

    elm = File.open(expected_other_filepath, 'r').read(nil)
    expect(elm).to eq(<<~ELM)
      module Edge.ApplicationController.Another exposing (json)


      json : String
      json =
          """
      {
        "example": "data"
      }
          """
    ELM
  end
end
