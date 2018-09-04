require 'action_dispatch'
require 'action_controller'
require 'action_controller/test_case'

module RailsEdgeTest::Dsl
  Edge = Struct.new(:description, :action, :controller_class) do

    def initialize(*args)
      super
      @let_cache = {}
    end

    delegate :session, to: :request

    def request
      @request ||= ActionController::TestRequest.new
    end

    def controller
      @controller ||= controller_class.new
    end

    def response
      @response
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
  end
end
