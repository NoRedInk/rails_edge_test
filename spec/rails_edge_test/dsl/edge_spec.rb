require 'rails_helper'

module Namespace
  class MyObj
    def as_json
      { isMyObj: true }
    end
  end

  class EdgeController < ActionController::Base
    def simple
      render json: {my: 'response'}
    end

    def escape
      render json: {escape: 'this "string" please'}
    end

    def ivar
      @page_data = {to: 'be embedded'}
      head :ok
    end

    def ivar_requires_as_json
      @page_data = { field: MyObj.new }
      head :ok
    end
  end
end

RSpec.describe RailsEdgeTest::Dsl::Edge do
  before(:all) do
    Rails.application.routes.draw do
      get 'test/simple' => 'namespace/edge#simple'
      get 'test/escape' => 'namespace/edge#escape'
      get 'test/ivar' => 'namespace/edge#ivar'
      get 'test/ivar_requires_as_json' => 'namespace/edge#ivar_requires_as_json'
    end
  end
  after(:all) do
    Rails.application.reload_routes!
  end

  before do
    RailsEdgeTest::Dsl.reset!

    RailsEdgeTest.configure do |config|
      config.elm_path = elm_path
    end

    # ensure the elm_path directory always starts empty
    begin
      FileUtils.remove_entry_secure(File.join(elm_path, 'Edge'))
    rescue Errno::ENOENT
    end
  end


  let(:elm_path) { File.expand_path('../../tmp', File.dirname(__FILE__)) }

  describe "#produce_elm_file(module_name, ivar: nil)" do
    let(:expected_filepath) {
      File.join(
        elm_path,
        'Edge/Namespace/EdgeController/',
        module_name+'.elm'
      )
    }
    let(:module_name) { 'MyResponse' }

    it "creates a file in the expected location" do
      expect(File.exists? expected_filepath).to be false

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            edge "elm" do
              perform_get
              produce_elm_file('MyResponse')
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(File.exists? expected_filepath).to be true
    end

    it "creates a file with the expected contents" do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            edge "elm" do
              perform_get
              produce_elm_file('MyResponse')
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      elm = File.open(expected_filepath, 'r').read(nil)
      expect(elm).to eq(<<~ELM)
        module Edge.Namespace.EdgeController.MyResponse exposing (json)


        json : String
        json =
            """
        {
          "my": "response"
        }
            """
      ELM
    end

    it "properly escapes the json string" do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :escape do
            edge "elm" do
              perform_get
              produce_elm_file('MyResponse')
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      elm = File.open(expected_filepath, 'r').read(nil)
      expect(elm).to eq(<<~ELM)
        module Edge.Namespace.EdgeController.MyResponse exposing (json)


        json : String
        json =
            """
        {
          "escape": "this \\\\"string\\\\" please"
        }
            """
      ELM
    end

    it "can grab the json out of an instance variable" do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :ivar do
            edge "elm" do
              perform_get
              produce_elm_file('MyResponse', ivar: :@page_data)
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      elm = File.open(expected_filepath, 'r').read(nil)
      expect(elm).to eq(<<~ELM)
        module Edge.Namespace.EdgeController.MyResponse exposing (json)


        json : String
        json =
            """
        {
          "to": "be embedded"
        }
            """
      ELM
    end

    it "can correctly renders ivars containing objects that define as_json " do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :ivar_requires_as_json do
            edge "elm" do
              perform_get
              produce_elm_file('MyResponse', ivar: :@page_data)
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      elm = File.open(expected_filepath, 'r').read(nil)
      expect(elm).to eq(<<~ELM)
        module Edge.Namespace.EdgeController.MyResponse exposing (json)


        json : String
        json =
            """
        {
          "field": {
            "isMyObj": true
          }
        }
            """
      ELM
    end
  end
end
