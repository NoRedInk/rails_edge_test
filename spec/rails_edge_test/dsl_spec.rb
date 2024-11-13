# frozen_string_literal: true

require 'rails_helper'

class MyController < ActionController::Base
  def simple
    render json: { my: 'response' }
  end

  def complex
    if request.xhr?
      render json: { local: 'info', params: params, session: session.to_h }
    else
      redirect_to '/'
    end
  end

  def post_action
    render json: { hello: 'world' }
  end

  def delete_action
    render json: { this: 'deletes' }
  end
end

AnotherController = Class.new ActionController::Base do
  def another
    render json: { another: 'response' }
  end
end

RSpec.describe RailsEdgeTest::Dsl do
  before(:all) do
    Rails.application.routes.draw do
      get 'test/simple' => 'my#simple'
      get 'test/complex' => 'my#complex'
      post 'test/post_action' => 'my#post_action'
      delete 'test/delete_action' => 'my#delete_action'

      get 'test/another' => 'another#another'
    end
  end

  after(:all) do
    Rails.application.reload_routes!
  end

  before do
    RailsEdgeTest::Dsl.reset!
  end

  context 'within an edge' do
    it 'has access to an instance of the specific controller' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'do very little' do
              test_value = controller
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to be_a MyController
    end

    it 'has access to a Request object' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'do very little' do
              test_value = request
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value).to be_a ActionController::TestRequest
    end

    it 'has access to a Session object' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'set the session' do
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

    it 'can perform a get request' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'get :simple' do
              test_value = perform_get
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value[0]).to eq 200
      expect(test_value[1]).to be_a Hash
      expect(test_value[2]).to be_a ActionDispatch::Response::RackBody
      expect(test_value[2].body).to eq({ my: 'response' }.to_json)
    end

    it 'can perform a post request' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :post_action do
            edge 'post :post_action' do
              test_value = perform_post
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value[0]).to eq 200
      expect(test_value[1]).to be_a Hash
      expect(test_value[2]).to be_a ActionDispatch::Response::RackBody
      expect(test_value[2].body).to eq({ hello: 'world' }.to_json)
    end

    it 'can perform a delete request' do
      test_value = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :delete_action do
            edge 'delete :delete_action' do
              test_value = perform_delete
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value[0]).to eq 200
      expect(test_value[1]).to be_a Hash
      expect(test_value[2]).to be_a ActionDispatch::Response::RackBody
      expect(test_value[2].body).to eq({ this: 'deletes' }.to_json)
    end

    it 'can set authenticity token for the request' do
      test_request = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'set the authenticity token' do
              test_request = request

              set_authenticity_token
            end
          end
        end
      end

      allow_any_instance_of(MyController).to receive(:form_authenticity_token).and_return('a_test_token') # rubocop:disable RSpec/AnyInstance
      RailsEdgeTest::Dsl.execute!

      expect(test_request.headers['X-CSRF-Token']).to eq 'a_test_token'
    end

    it 'can incorporate request, session, and params when making a request' do
      test_value = nil
      expected_value = {
        local: 'info',
        params: { adele: 'hello', controller: 'my', action: 'complex' },
        session: { britney: 'toxic' }
      }

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :complex do
            edge 'get :complex' do
              request.headers['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
              session[:britney] = 'toxic'
              test_value = perform_get(adele: 'hello')
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value[0]).to eq 200
      expect(test_value[1]).to be_a Hash
      expect(test_value[2]).to be_a ActionDispatch::Response::RackBody
      expect(test_value[2].body).to eq(expected_value.to_json)
    end

    it 'executes multiple edges on the same action' do
      test_value_one = nil
      test_value_two = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'get :simple' do
              test_value_one = perform_get
            end

            edge 'just looking' do
              test_value_two = controller
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value_one[2].body).to eq({ my: 'response' }.to_json)
      expect(test_value_two).to be_a MyController
    end

    it 'executes multiple edges on different actions' do
      test_value_one = nil
      test_value_two = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'get :simple' do
              test_value_one = perform_get
            end
          end

          action :complex do
            edge 'redirecting' do
              test_value_two = perform_get
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value_one[2].body).to eq({ my: 'response' }.to_json)
      expect(test_value_two[0]).to eq 302
    end

    it 'executes multiple edges on different controllers' do
      test_value_one = nil
      test_value_two = nil

      Module.new do
        extend RailsEdgeTest::Dsl

        controller MyController do
          action :simple do
            edge 'get :simple' do
              test_value_one = perform_get
            end
          end
        end
      end

      Module.new do
        extend RailsEdgeTest::Dsl

        controller AnotherController do
          action :another do
            edge 'get :another' do
              test_value_two = perform_get
            end
          end
        end
      end

      RailsEdgeTest::Dsl.execute!

      expect(test_value_one[2].body).to eq({ my: 'response' }.to_json)
      expect(test_value_two[2].body).to eq({ another: 'response' }.to_json)
    end
  end
end
