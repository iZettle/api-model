module ApiModel
  class HttpRequest
    include Initializer

    attr_accessor :path, :method, :options, :api_call, :builder, :config, :cache_id

    after_initialize :set_default_options

    define_model_callbacks :run_request

    # There is a bug in Rails 4.2 where you can't create instances of classes that have `define_model_callbacks :run`
    # To get around this we internally rename the callback to `run_request`, and alias the methods `before_run` to `before_run_request`
    # This can be removed when the Rails version is fixed.
    class << self
      alias_method :around_run, :around_run_request
      alias_method :before_run, :before_run_request
      alias_method :after_run, :after_run_request
    end

    def config
      @config ||= Configuration.new
    end

    def run
      run_callbacks :run_request do
        Log.debug "#{method.to_s.upcase} #{full_path} with headers: #{options[:headers]}"
        self.api_call = Typhoeus.send method, full_path, options
        Response.new self, config
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

    private

    def set_default_options
      options[:headers] ||= {}
      options[:headers].reverse_merge! config.headers if config.try(:headers)
    end

  end
end
