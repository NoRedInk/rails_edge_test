require 'rails_helper'

module Namespace
  class ConfigurationController < ActionController::Base
    def simple
      render json: {my: 'response'}
    end
  end
end

RSpec.describe RailsEdgeTest::Configuration do
  before(:all) do
    Rails.application.routes.draw do
      get 'test/simple' => 'namespace/edge#simple'
    end
  end
  after(:all) do
    Rails.application.reload_routes!
  end

  before do
    RailsEdgeTest::Dsl.reset!
  end


  describe "#include(mod)" do
    it "includes the mod in each edge" do
      meant_to = nil

      nicki = Module.new do
        define_method :starships do
          meant_to = 'fly!'
        end
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::ConfigurationController do
          action :simple do
            edge "elm" do
              starships
            end
          end
        end
      end

      RailsEdgeTest.configure do |config|
        config.include(nicki)
      end

      RailsEdgeTest::Dsl.execute!

      expect(meant_to).to eq 'fly!'
    end
  end
end
