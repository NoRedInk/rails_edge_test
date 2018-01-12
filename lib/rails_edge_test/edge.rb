require 'action_dispatch'
require 'action_controller'
require 'action_controller/test_case'

module RailsEdgeTest
  Edge = Struct.new(:description, :action, :controller_class) do

    delegate :session, to: :request

    def request
      @request ||= ActionController::TestRequest.new
    end

    def controller
      @controller ||= controller_class.new
    end

    def perform_get(parameters = {})
      request.assign_parameters(
        ::Rails.application.routes,
        controller_class.controller_path,
        action.to_s,
        parameters
      )

      @response = controller.dispatch(action, request)
    end

    def __define_lets(lets_handler)
      @let_cache = {}
      lets_handler.let_blocks.each do |title, block|
        define_singleton_method(title) do
          @let_cache[title] ||= instance_eval(&block)
        end
      end
    end
  end
end
