require 'action_dispatch'
require 'action_controller'
require 'action_controller/test_case'

module RailsEdgeTest::Dsl
  Edge = Struct.new(:description, :action) do

    def initialize(*args)
      super
      @let_cache = {}
    end

    delegate :controller_class, to: :action
    delegate :session, to: :request

    def request
      @request ||= ActionController::TestRequest.create(controller_class)
    end

    # In the context of the edge, we want `controller` to be the rails controller
    # instead of our own RailsEdgeTest::Dsl::Controller. In this way the user can
    # directly access the rails controller within their edge.
    def controller
      @controller ||= controller_class.new
    end

    def response
      @response
    end

    def perform_get(parameters={})
      process(parameters)
    end

    def perform_post(parameters={})
      request.instance_variable_set(:@method, "POST")
      request.env['REQUEST_METHOD'] = "POST"
      process(parameters)
    end

    def process(parameters = {})
      request.assign_parameters(
        ::Rails.application.routes,
        controller_class.controller_path,
        action.name.to_s,
        parameters.stringify_keys!,
        '',
        ''
      )

      response = ActionDispatch::Response.new.tap do |res|
        res.request = request
      end

      @response = controller.dispatch(action.name, request, response)
    end

    def produce_elm_file(module_name, ivar: nil)
      json = produce_json(ivar: ivar)
      json = json.gsub("\\", "\\\\\\\\") # unbelievably, this replaces \ with \\

      filepath = File.join(
        RailsEdgeTest.configuration.elm_path,
        'Edge',
        controller_class.name.gsub('::','/')
      )

      full_module_name =
        "#{controller_class.name.gsub('::','.')}.#{module_name}"

      data = <<~ELM
        module Edge.#{full_module_name} exposing (json)


        json : String
        json =
            """
        #{json}
            """
      ELM

      write_file(filepath, module_name+'.elm', data)
    end

    private

    def produce_json(ivar: nil)
      unless response
        fail "Must perform a request (for example `perform_get`) before attempting to produce a json file."
      end

      if response.is_a?(Array) && response[0] >= 300
        fail "Request did not result in a successful (2xx) response!"
      end

      ActiveSupport::JSON::Encoding.escape_html_entities_in_json = false
      if ivar
        value = controller.send(:instance_variable_get, ivar)
        JSON.pretty_unparse(value.as_json)
      elsif response[1]['Content-Type']&.starts_with?('application/json')
        value = JSON.parse(response[2].body)
        JSON.pretty_unparse(value)
      else
        response[2].body
      end
    end

    def write_file(filepath, filename, data)
      FileUtils.mkdir_p(filepath)

      filepath = File.join(filepath, filename)

      File.open(filepath, 'w') do |f|
        f.write(data)
        f.flush
      end
    end

    # support calling methods defined in action
    def method_missing(method_name, *arguments, &block)
      if action.respond_to?(method_name)
        action.public_send(method_name, *arguments, &block)
      else
        super
      end
    end

    # always define respond_to_missing? when defining method_missing:
    # https://thoughtbot.com/blog/always-define-respond-to-missing-when-overriding
    def respond_to_missing?(method_name, include_private = false)
      action.respond_to?(method_name) || super
    end
  end
end
