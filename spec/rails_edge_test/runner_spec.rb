# frozen_string_literal: true

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
    FileUtils.rm_rf(elm_path.join('Edge'))
  end

  it 'creates the files with the expected contents' do
    expect(File.exist?(expected_home_filepath)).to be false
    expect(File.exist?(expected_other_filepath)).to be false

    RailsEdgeTest::Runner.go!

    expect(File.exist?(expected_home_filepath)).to be true
    expect(File.exist?(expected_other_filepath)).to be true

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

  it 'allows full paths for creating files' do
    expect(File.exist?(expected_home_filepath)).to be false
    expect(File.exist?(expected_other_filepath)).to be false

    # Provide full filepath relative to root
    RailsEdgeTest::Runner.go!(['spec/support/test_app/edge/another_edge.rb'])

    expect(File.exist?(expected_home_filepath)).to be false
    expect(File.exist?(expected_other_filepath)).to be true

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
