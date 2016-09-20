require 'net/http'
require 'json'

module ClubhouseRuby
  class Request
    attr_accessor :method, :uri, :response_format, :params

    #def initialize(path:, method:, response_format:, token:, params: {})
    def initialize(call_object, method:, params: {})
      raise ArgumentError unless validate_input(call_object, method, params)

      self.uri = construct_uri(call_object, params)
      self.method = method
      self.response_format = call_object.response_format
      self.params = params
    end

    def fetch
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
        req = Net::HTTP.const_get(method.capitalize).new(uri)

        set_body(req)
        set_format_header(req)

        wrap_response(https.request(req))
      end
    end

    private

    def validate_input(call_object, method, params)
      !call_object.path.nil? &&
        !call_object.token.nil? &&
        !call_object.response_format.nil? &&
        ClubhouseRuby::METHODS.keys.include?(method) &&
        params.is_a?(Hash) || params.nil?
    end

    def construct_uri(call_object, params)
      base_url = ClubhouseRuby::API_URL
      path = call_object.path.join('/')
      object_id = params.delete(:id).to_s
      auth = "?token=#{call_object.token}"
      URI(base_url + path + object_id + auth)
    end

    def set_format_header(req)
      format_header = ClubhouseRuby::FORMATS[response_format][:header]
      format_content = ClubhouseRuby::FORMATS[response_format][:content]
      req[format_header] = format_content
    end

    def set_body(req)
      req.body = params.to_json if params
    end

    def wrap_response(res)
      # TODO
      # decorate errors
      # wrap with status
      res
    end
  end
end