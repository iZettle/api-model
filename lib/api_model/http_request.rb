module ApiModel
  class HttpRequest
    include Initializer

    attr_accessor :path, :method, :options, :request_adapter, :response, :builder, :config, :cache_id

    after_initialize :set_default_options

    define_model_callbacks :run

    def config
      @config ||= Configuration.new
    end

    def run
      run_callbacks :run do
        Log.debug "#{method.to_s.upcase} #{full_path} with headers: #{options[:headers]}"
        self.request_adapter = @config.request_adapter.new self
        self.response = self.request_adapter.run
        Response.new self, config
      end
    end

    def method
      @method ||= :get
    end

    def options
      @options ||= {}
    end

    def request_options
      @request_options ||= HttpRequestOptions.new options
    end

    def full_path
      return path if path =~ /^http/
      "#{config.host}#{path}"
    end

    def request_method
      request_adapter.request_method
    end

    def body
      response.body
    end

    def success?
      response.success?
    end

    private

    def set_default_options
      options[:headers] ||= {}
      options[:headers].reverse_merge! config.headers if config.try(:headers)
    end

  end
end