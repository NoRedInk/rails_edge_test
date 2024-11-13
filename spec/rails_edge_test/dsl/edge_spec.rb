# frozen_string_literal: true

require 'rails_helper'

module Namespace
  class MyObj
    def as_json
      { isMyObj: true }
    end
  end

  class EdgeController < ActionController::Base
    def simple
      render json: { my: 'response' }
    end

    def escape
      render json: { escape: 'this "string" please' }
    end

    def ivar
      @page_data = { to: 'be embedded' }
      head :ok
    end

    def ivar_requires_as_json
      @page_data = { field: MyObj.new }
      head :ok
    end
  end

  class EdgeController2 < EdgeController
  end
end

RSpec.describe RailsEdgeTest::Dsl::Edge do
  # rubocop:disable RSpec/BeforeAfterAll
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
  # rubocop:enable RSpec/BeforeAfterAll

  before do
    RailsEdgeTest::Dsl.reset!

    RailsEdgeTest.configure do |config|
      config.elm_path = elm_path
    end

    # ensure the elm_path directory always starts empty
    FileUtils.rm_rf(File.join(elm_path, 'Edge'))
  end

  let(:elm_path) { File.expand_path('../../tmp', File.dirname(__FILE__)) }

  describe '#produce_elm_file(module_name, ivar: nil)' do
    let(:expected_filepath) do
      File.join(
        elm_path,
        'Edge/Namespace/EdgeController/',
        "#{module_name}.elm"
      )
    end
    let(:module_name) { 'MyResponse' }

    it 'creates a file in the expected location' do
      expect(File.exist?(expected_filepath)).to be false

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            edge 'elm' do
              perform_get
              produce_elm_file('MyResponse')
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(File.exist?(expected_filepath)).to be true
    end

    it 'creates a file with the expected contents' do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            edge 'elm' do
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

    it 'properly escapes the json string' do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :escape do
            edge 'elm' do
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

    it 'can grab the json out of an instance variable' do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :ivar do
            edge 'elm' do
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

    it 'can correctly renders ivars containing objects that define as_json' do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :ivar_requires_as_json do
            edge 'elm' do
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

  describe 'a method defined within an action block' do
    it 'is callable within an edge block inside that action block' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            def christina
              'genie in a bottle'
            end

            edge 'call method' do
              test_value = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a bottle'
    end

    it 'is callable with arguments and optional block' do
      test_value = nil
      block_test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            def christina(what, &block)
              block&.call(what)
              "#{what} in a bottle"
            end

            edge 'call method' do
              # verify it works without a block
              christina('genie')

              # verify it works with a block
              test_value = christina('genie') do |name|
                block_test_value = name
              end
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a bottle'
      expect(block_test_value).to eq 'genie'
    end

    it 'is not callable within a different action block' do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            def christina
              'genie in a bottle'
            end

            edge 'call method' do
              christina
            end
          end
          action :simple do
            edge 'invalid' do
              christina
            end
          end
        end
      end

      expect do
        RailsEdgeTest::Dsl.execute!
      end.to raise_error(NameError, /christina/)
    end

    it 'is callable from a let block' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          action :simple do
            def christina
              'genie in the dark'
            end

            let(:gaga) { christina.gsub('genie', 'dance') }

            edge 'callable from let' do
              test_value = gaga
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'dance in the dark'
    end
  end

  describe 'a method defined within a controller block' do
    it 'is callable within an edge block inside that controller block' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          def christina
            'genie in a bottle'
          end

          action :simple do
            edge 'call method' do
              test_value = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a bottle'
    end

    it 'allows to be called from multiple actions' do
      first_result = second_result = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          def christina
            'genie in a bottle'
          end

          action :first do
            edge 'call method' do
              first_result = christina
            end
          end

          action :second do
            edge 'call method' do
              second_result = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(first_result).to eq 'genie in a bottle'
      expect(second_result).to eq 'genie in a bottle'
    end

    it 'allows to be overridden by a method defined in the action' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          def christina
            'genie in a bottle'
          end

          action :first do
            def christina
              'genie in a lamp'
            end

            edge 'call let' do
              test_value = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a lamp'
    end

    it 'allows let blocks inside an action to reference methods inside a controller' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::EdgeController do
          def christina
            'genie in a bottle'
          end

          action :first do
            let(:christie) { "#{christina} and a lamp" }

            edge 'call method' do
              test_value = christie
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a bottle and a lamp'
    end

    describe 'scoping' do
      it "can't be referenced across controllers" do
        Module.new do
          extend RailsEdgeTest::Dsl

          controller Namespace::EdgeController do
            def christina
              'genie in a bottle'
            end
          end

          controller Namespace::EdgeController2 do
            action :first do
              edge 'call method' do
                christina
              end
            end
          end
        end

        expect { RailsEdgeTest::Dsl.execute! }.to raise_error(NameError, /christina/)
      end

      it "can't be referenced across actions" do
        test_value = nil
        Module.new do
          extend RailsEdgeTest::Dsl

          controller Namespace::EdgeController do
            action :first do
              def christina
                'genie in a bottle'
              end

              edge 'call method' do
                test_value = christina
              end
            end

            action :second do
              edge 'call method with failure' do
                christina
              end
            end
          end
        end

        expect { RailsEdgeTest::Dsl.execute! }.to raise_error(NameError, /christina/)
        expect(test_value).to eq('genie in a bottle')
      end
    end
  end
end
