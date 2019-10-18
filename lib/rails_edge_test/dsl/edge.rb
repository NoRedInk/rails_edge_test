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
      @request ||= ActionController::TestRequest.create(controller_class)
    end

    def controller
      @controller ||= controller_class.new
    end

    def response
      @response
    end

    def idems
      @idems ||= []
    end

    def perform_get(parameters = {})
      request.assign_parameters(
        ::Rails.application.routes,
        controller_class.controller_path,
        action.to_s,
        parameters.stringify_keys!,
        '',
        ''
      )

      response = ActionDispatch::Response.new.tap do |res|
        res.request = request
      end

      @response = controller.dispatch(action, request, response)
    end

    def add_idempotence_rule(&rule)
      idems << rule
    end

    def pin_value(path, value)
      # Takes "(["key1", "key2"], pinnedValue)" and runs
      # > json_data["key1"]["key2"] = pinnedValue
      # It will error if the specified path doesn't already
      # exist
      # see https://stackoverflow.com/questions/14294751/how-to-set-nested-hash-in-ruby-dynamically for how this works
      add_idempotence_rule do |json_data|
        *keys, last = path
        parent = keys.inject(json_data, :fetch)
        if parent.has_key? last
          parent[last] = value
        else
          raise KeyError, "key not found: \"#{last}\""
        end
        json_data
      end
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
        sanitize_json(value.as_json)
      elsif response[1]['Content-Type']&.starts_with?('application/json')
        value = JSON.parse(response[2].body)
        sanitize_json(value)
      else
        response[2].body
      end
    end

    def sanitize_json(json_data)
      sanitized = idems.reduce(json_data) { |jd, idem| idem.call jd }
      JSON.pretty_unparse(sanitized)
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
