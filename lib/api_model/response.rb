module ApiModel
  class Response
    attr_accessor :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    # TODO - make json root configurable
    def build_objects(builder)
      if json_response_body.is_a? Array
        json_response_body.collect{ |hash| build builder, hash }
      elsif json_response_body.is_a? Hash
        build builder, json_response_body
      end
    end

    def build(builder, hash)
      if builder.respond_to? :build
        builder.build hash
      else
        builder.new hash
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