module ApiModel
  module RestMethods

    def get_json(path, params={}, options={})
      call_api :get, path, options.merge(params: params)
    end

    def post_json(path, body=nil, options={})
      body = body.to_json if body.is_a?(Hash)
      call_api :post, path, options.merge(body: body)
    end

    def call_api(method, path, options={})
      request = HttpRequest.new path: path, method: method, config: api_model_configuration
      request.builder = options.delete(:builder) || self
      request.options.merge! options
      request.run.build_objects
    end

  end
end