module ApiModel
  class Response
    FALL_THROUGH_METHODS = [
      :class, :nil?, :empty?, :acts_like?, :as_json, :blank?, :duplicable?,
      :eval_js, :html_safe?, :in?, :presence, :present?, :psych_to_yaml, :to_json,
      :to_param, :to_query, :to_yaml, :to_yaml_properties, :with_options, :is_a?,
      :respond_to?, :kind_of?
    ]

    attr_accessor :http_response, :objects

    def initialize(http_response)
      @http_response = http_response
    end

    # TODO - make json root configurable
    def build_objects
      if json_response_body.is_a? Array
        self.objects = json_response_body.collect{ |hash| build http_response.builder, hash }
      elsif json_response_body.is_a? Hash
        self.objects = self.build http_response.builder, json_response_body
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
      JSON.parse http_response.api_call.body
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

  end
end