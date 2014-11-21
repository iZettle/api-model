module ApiModel
  module ClassMethods

    def attribute_synonym(primary_method_name, *alternate_names)
      alternate_names.each do |alternate_name|
        alias_method "#{alternate_name}=".to_sym, "#{primary_method_name}=".to_sym
      end
    end

    def get_json(path, params={}, options={})
      call_api :get, path, options.merge(params: params)
    end

    def post_json(path, body=nil, options={})
      call_api_with_json :post, path, body, options
    end

    def put_json(path, body=nil, options={})
      call_api_with_json :put, path, body, options
    end

    def call_api_with_json(method, path, body=nil, options={})
      body = body.to_json if body.is_a?(Hash)
      call_api method, path, options.merge(body: body)
    end

    def call_api(method, path, options={})
      cache options.delete(:cache_id) || cache_id(path, options) do
        request = HttpRequest.new path: path, method: method, config: api_model_configuration
        request.builder = options.delete(:builder) || api_model_configuration.builder || self
        request.options.deep_merge! options
        request.run.build_objects
      end
    end

    def cache_id(path, options={})
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