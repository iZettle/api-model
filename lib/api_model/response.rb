module ApiModel
  class Response
    attr_accessor :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    # TODO - make json root configurable
    def build_objects(builder)
      if json_response_body.is_a? Array
        json_response_body.collect{ |hash| builder.new hash }
      elsif json_response_body.is_a? Hash
        builder.new json_response_body
      end
    end

    def json_response_body
      JSON.parse http_response.body
    rescue JSON::ParserError
      Log.info "Could not parse JSON response: #{http_response.body}"
      return nil
    end

  end
end