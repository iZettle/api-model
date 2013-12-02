module ApiModel
  module RestMethods

    def get_json(path, options={})
      call_api :get, path, options
    end

    def post_json(path, options={})
      call_api :post, path, options
    end

    def call_api(method, path, options={})
      request = HttpRequest.new path: path, method: method, caller: self, config: api_model_configuration
      request.builder = options.delete(:builder) || self
      request.options = options
      request.run.build_objects
    end

  end
end