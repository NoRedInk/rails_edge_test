require 'rails_helper'

MyController = Class.new ActionController::Base do
  def new
    render json: {my: 'response'}
  end
end

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

    it "has access to a Request object" do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :new do
            edge "do very little" do
              test_value = request
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to be_a ActionController::TestRequest
    end

    it "has access to a Session object" do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :new do
            edge "set the session" do
              test_value = session
              session[:beyonce] = 'run the world'
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to be_a ActionController::TestSession
      expect(test_value[:beyonce]).to eq 'run the world'
    end

    it "can perform a get request" do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :new do
            edge "get :new" do
              test_value = perform_get
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value[0]).to eq 200
      expect(test_value[1]).to be_a Hash
      expect(test_value[2]).to be_a ActionDispatch::Response::RackBody
      expect(test_value[2].body).to eq({my: 'response'}.to_json)
    end
  end
end
