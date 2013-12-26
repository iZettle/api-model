module ApiModel
  module ClassMethods

    def get_json(path, params={}, options={})
      call_api :get, path, options.merge(params: params)
    end

    def post_json(path, body=nil, options={})
      body = body.to_json if body.is_a?(Hash)
      call_api :post, path, options.merge(body: body)
    end

    def call_api(method, path, options={})
      cache cache_id(path, options) do
        request = HttpRequest.new path: path, method: method, config: api_model_configuration
        request.builder = options.delete(:builder) || api_model_configuration.builder || self
        request.options.merge! options
        request.run.build_objects
      end
    end

    def cache_id(path, options={})
      return @cache_id if @cache_id
      p = (options[:params] || {}).collect{ |k,v| "#{k}#{v}" }.join("")
      "#{path}#{p}"
    end

    def cache(path, &block)
      api_model_configuration.cache_strategy.new(path, api_model_configuration.cache_settings).cache do
        block.call
      end
    end

  end
end