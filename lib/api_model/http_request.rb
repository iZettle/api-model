module ApiModel
  class HttpRequest
    include ApiModel::Initializer

    attr_accessor :path, :method, :options, :api_call, :builder, :config, :cache_id

    after_initialize :set_default_options

    define_model_callbacks :run

    def config
      @config ||= Configuration.new
    end

    def run
      run_callbacks :run do
        config.cache_strategy.new(cache_id).cache do
          self.api_call = Typhoeus.send method, full_path, options
          Response.new self, config
        end
      end
    end

    def method
      @method ||= :get
    end

    def options
      @options ||= {}
    end

    def full_path
      return path if path =~ /^http/
      "#{config.host}#{path}"
    end

    def request_method
      api_call.request.original_options[:method]
    end

    def cache_id
      return @cache_id if @cache_id
      p = (options[:params] || {}).collect{ |k,v| "#{k}#{v}" }.join("")
      "#{path}#{p}"
    end

    private

    def set_default_options
      options[:headers] ||= {}
      options[:headers].reverse_merge! config.headers if config.try(:headers)
    end

  end
end