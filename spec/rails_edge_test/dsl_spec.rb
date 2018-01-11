require 'spec_helper'

MyController = Class.new

RSpec.describe RailsEdgeTest::Dsl do
  before do
    RailsEdgeTest::Dsl.reset!
  end

  context "within an edge" do

    it "has access to an instance of the specific controller" do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :new do
            edge "do very little" do
              test_value = controller
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to be_a MyController
    end
  end
end
