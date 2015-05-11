module ApiModel
  class Response
    FALL_THROUGH_METHODS = [
      :class, :nil?, :empty?, :acts_like?, :as_json, :blank?, :duplicable?,
      :eval_js, :html_safe?, :in?, :presence, :present?, :psych_to_yaml, :to_json,
      :to_param, :to_query, :to_yaml, :to_yaml_properties, :with_options, :is_a?,
      :respond_to?, :kind_of?
    ]

    attr_accessor :http_response, :objects

    def initialize(http_response, config)
      @http_response = http_response
      @_config = config || Configuration.new
    end

    def metadata
      @metadata ||= OpenStruct.new
    end

    def build_objects
      raise UnauthenticatedError if @_config.raise_on_unauthenticated && http_response.api_call.response_code == 401
      raise NotFoundError if @_config.raise_on_not_found && http_response.api_call.response_code == 404
      raise ServerError if @_config.raise_on_server_error && http_response.api_call.response_code == 500
      return self if response_body.nil?

      if response_build_hash.is_a? Array
        self.objects = response_build_hash.collect{ |hash| build http_response.builder, hash }
      else
        self.objects = self.build http_response.builder, response_build_hash
      end

      self
    end

    def build(builder, hash)
      if builder.respond_to? :build
        builder.build hash
      else
        builder.new hash
      end
    end

    def response_body
      @response_body ||= @_config.parser.parse http_response.api_call.body
    end

    def successful?
      http_response.api_call.success?
    end

    def response_cookies
      return @cookies if @cookies.present?
      jar = HTTP::CookieJar.new

      set_cookie = http_response.api_call.headers_hash["Set-Cookie"]
      set_cookie = set_cookie.split(", ") unless set_cookie.is_a?(Array)

      set_cookie.each do |cookie|
        jar.parse cookie, http_response.api_call.request.base_url
      end

      @cookies = jar.cookies
    end

    # Define common methods which should never be called on this abstract class, and should always be
    # passed down to the #objects
    FALL_THROUGH_METHODS.each do |transparent_method|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{transparent_method}(*args, &block)
          objects.send '#{transparent_method}', *args, &block
        end
      RUBY_EVAL
    end

    # Pass though any method which is not defined to the built objects. This makes the response class
    # quite transparent, and keeps the response acting like the built object, or array of objects.
    def method_missing(method_name, *args, &block)
      objects.send method_name, *args, &block
    end

    # Uses a string notation split by colons to fetch nested keys from a hash. For example, if you have a hash
    # which looks like:
    #
    #   { foo: { bar: { baz: "Hello world" } } }
    #
    # Then calling ++fetch_from_body("foo.bar.baz")++ would return "Hello world"
    def fetch_from_body(key_reference)
      key_reference.split(".").inject(response_body) do |hash,key|
        begin
          hash.fetch(key, nil)
        rescue NoMethodError
          Log.error "Could not set #{key_reference} on #{hash}"
        end
      end
    end

    # If the model config defines a json root, use it on the response_body
    # to dig down in to the hash.
    def response_build_hash
      if @_config.json_root.present?
        begin
          fetch_from_body @_config.json_root
        rescue
          raise ResponseBuilderError, "Could not find key #{@_config.json_root} in:\n#{response_body}"
        end
      else
        response_body
      end
    end

  end
end
