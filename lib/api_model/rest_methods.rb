module ApiModel
  module RestMethods

    def api_host=(api_host)
      @api_host = api_host
    end

    def api_host
      @api_host || ""
    end

    def get_json(path, options={})
      call_api :get, path, options
    end

    def post_json(path, options={})
      call_api :post, path, options
    end

    def call_api(method, path, options={})
      request = HttpRequest.new path: path, method: method, api_host: api_host, caller: self
      request.builder = options.delete(:builder) || self
      request.options = options
      request.run.build_objects
    end

  end
end