# frozen_string_literal: true

require 'rails_helper'

class LetHandlerController < ActionController::Base
  def simple
    render json: { my: 'response' }
  end
end

RSpec.describe RailsEdgeTest::Dsl::LetHandler do
  before(:all) do
    Rails.application.routes.draw do
      get 'test/simple' => 'let_handler#simple'
    end
  end

  after(:all) do
    Rails.application.reload_routes!
  end

  before do
    RailsEdgeTest::Dsl.reset!
  end

  describe 'a let block defined within an action block' do
    it 'is callable within an edge block inside that action block' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          action :simple do
            let(:christina) { 'genie in a bottle' }
            edge 'call let' do
              test_value = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a bottle'
    end

    it 'is not callable within a different action block' do
      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          action :simple do
            let(:christina) { 'genie in a bottle' }
            edge 'call let' do
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

    it 'is callable from another let block' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          action :simple do
            let(:christina) { 'genie in the dark' }
            let(:gaga) { christina.gsub('genie', 'dance') }
            edge 'cascade let' do
              test_value = gaga
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'dance in the dark'
    end

    it 'is executed on the first call and then cached' do
      test_value_one = nil
      test_value_two = nil
      value = 5

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          action :simple do
            let(:christina) { value *= 5 }
            edge 'call let twice' do
              test_value_one = christina
              test_value_two = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(value).to eq 25
      expect(test_value_one).to eq 25
      expect(test_value_two).to eq 25
    end
  end

  describe 'a let block defined within a controller block' do
    it 'is callable within an edge block inside that controller block' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          let(:christina) { 'genie in a bottle' }
          action :simple do
            edge 'call let' do
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

        controller LetHandlerController do
          let(:christina) { 'genie in a bottle' }
          action :first do
            edge 'call let' do
              first_result = christina
            end
          end
          action :second do
            edge 'call let' do
              second_result = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(first_result).to eq 'genie in a bottle'
      expect(second_result).to eq 'genie in a bottle'
    end

    it 'allows to be overridden by a let defined in the action' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          let(:christina) { 'genie in a bottle' }
          action :first do
            let(:christina) { 'genie in a lamp' }
            edge 'call let' do
              test_value = christina
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a lamp'
    end

    it 'allows let blocks inside an action to reference let blocks inside a controller' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          let(:christina) { 'genie in a bottle' }
          action :first do
            let(:christie) { "#{christina} and a lamp" }
            edge 'call let' do
              test_value = christie
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'genie in a bottle and a lamp'
    end
  end

  describe 'a generate block' do
    it "is the same as a let block, but prefixed by 'generate_' when called" do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller LetHandlerController do
          action :simple do
            generate(:duet) { 'do what you want' }
            edge 'call generate' do
              test_value = generate_duet
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to eq 'do what you want'
    end
  end
end
