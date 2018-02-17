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

    def __define_lets(lets_handler)
      @let_cache = {}
      lets_handler.let_blocks.each do |title, block|
        define_singleton_method(title) do
          @let_cache[title] ||= instance_eval(&block)
        end
      end
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
        controller.
          send(:instance_variable_get, ivar).
          to_json
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
