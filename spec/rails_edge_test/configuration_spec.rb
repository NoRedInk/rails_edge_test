# frozen_string_literal: true

require 'rails_helper'

module Namespace
  class ConfigurationController < ActionController::Base
    def simple
      render json: { my: 'response' }
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

  describe '#include(mod)' do
    it 'makes module callable from helper functions' do
      count = 0

      increment_module = Module.new do
        define_method :increment_count do
          count += 1
        end
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::ConfigurationController do
          def controller_increment
            increment_count
          end

          action :simple do
            def action_increment
              increment_count
            end

            edge 'increment twice' do
              controller_increment
              action_increment
            end
          end
        end
      end

      RailsEdgeTest.configure do |config|
        config.include(increment_module)
      end

      RailsEdgeTest::Dsl.execute!

      expect(count).to eq 2
    end

    it 'includes the module in each edge' do
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
            edge 'blast off' do
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

  describe '#before_suite(&block)' do
    it 'executes the before_suite blocks before the edges' do
      count_down = 3

      RailsEdgeTest.configure do |config|
        config.before_suite { count_down -= 1 }
      end

      RailsEdgeTest.configure do |config|
        config.before_suite { count_down -= 1 }
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::ConfigurationController do
          action :simple do
            edge 't minus' do
              count_down -= 1
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(count_down).to eq 0
    end
  end

  describe '#before_each(&block)' do
    it 'executes the before_each blocks before each edge' do
      count_down = 7

      RailsEdgeTest.configure do |config|
        config.before_each { count_down -= 1 }
      end

      RailsEdgeTest.configure do |config|
        config.before_each { count_down -= 1 }
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::ConfigurationController do
          action :simple do
            edge 'first' do
              count_down -= 1
            end
          end

          action :simple do
            edge 'second' do
              count_down -= 1
              count_down -= 1
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(count_down).to eq 0
    end
  end

  describe '#after_each(&block)' do
    it 'executes the before_each blocks before each edge' do
      count_down = 7

      RailsEdgeTest.configure do |config|
        config.after_each { count_down -= 1 }
      end

      RailsEdgeTest.configure do |config|
        config.after_each { count_down -= 1 }
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::ConfigurationController do
          action :simple do
            edge 'first' do
              count_down -= 1
            end
          end

          action :simple do
            edge 'second' do
              count_down -= 1
              count_down -= 1
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(count_down).to eq 0
    end
  end

  describe 'before and after blocks' do
    it 'execute in the correct order' do
      order = []

      RailsEdgeTest.configure do |config|
        config.after_each { order << :first_after_each }
      end

      RailsEdgeTest.configure do |config|
        config.after_each { order << :second_after_each }
      end

      RailsEdgeTest.configure do |config|
        config.before_each { order << :first_before_each }
      end

      RailsEdgeTest.configure do |config|
        config.before_each { order << :second_before_each }
      end

      RailsEdgeTest.configure do |config|
        config.before_suite { order << :first_before_suite }
      end

      RailsEdgeTest.configure do |config|
        config.before_suite { order << :second_before_suite }
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller Namespace::ConfigurationController do
          action :simple do
            edge 'first' do
              order << :first_edge
            end
          end

          action :simple do
            edge 'second' do
              order << :second_edge
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(order).to eq %i[
        first_before_suite
        second_before_suite

        first_before_each
        second_before_each
        first_edge
        first_after_each
        second_after_each

        first_before_each
        second_before_each
        second_edge
        first_after_each
        second_after_each
      ]
    end
  end
end
