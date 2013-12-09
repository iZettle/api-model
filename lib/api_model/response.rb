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

    def build_objects
      raise UnauthenticatedError if @_config.raise_on_unauthenticated && http_response.api_call.response_code == 401
      raise NotFoundError if @_config.raise_on_not_found && http_response.api_call.response_code == 404
      return if json_response_body.nil?

      if response_build_hash.is_a? Array
        self.objects = response_build_hash.collect{ |hash| build http_response.builder, hash }
      elsif response_build_hash.is_a? Hash
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

    def json_response_body
      @json_response_body ||= JSON.parse http_response.api_call.body
    rescue JSON::ParserError
      Log.info "Could not parse JSON response: #{http_response.api_call.body}"
      return nil
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

    def method_missing(method_name, *args, &block)
      objects.send method_name, *args, &block
    end

    private

    # If the model config defines a json root, use it on the json_response_body
    # to dig down in to the hash.
    #
    # The root for a deeply nested hash will come in as a string with key names split
    # with a colon.
    def response_build_hash
      if @_config.json_root.present?
        begin
          @_config.json_root.split(".").inject(json_response_body) do |hash,key|
            hash.fetch(key)
          end
        rescue
          raise ResponseBuilderError, "Could not find key #{@_config.json_root} in:\n#{json_response_body}"
        end
      else
        json_response_body
      end
    end

  end
end