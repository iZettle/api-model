module ApiModel
  class Configuration
    include Initializer

    attr_accessor :host, :json_root, :headers, :raise_on_unauthenticated, :cache_settings,
                  :raise_on_not_found, :cache_strategy, :parser, :builder, :raise_on_server_error

    def self.from_inherited_config(config)
      new config.instance_values.reject {|k,v| v.blank? }
    end

    def headers
      @headers ||= {}
      @headers.reverse_merge "Content-Type" => "application/json; charset=utf-8",  "Accept" => "application/json"
    end

    def cache_strategy
      @cache_strategy ||= ApiModel::CacheStrategy::NoCache
    end

    def parser
      @parser ||= ApiModel::ResponseParser::Json.new
    end

    def cache_settings
      @cache_settings ||= {}
      @cache_settings.reverse_merge duration: 30.seconds, timeout: 2.seconds
    end
  end

  module ConfigurationMethods
    extend ActiveSupport::Concern

    module ClassMethods

      def reset_api_configuration
        @_api_config = nil
      end

      def api_model_configuration
        @_api_config || superclass.api_model_configuration
      rescue
        @_api_config = Configuration.new
      end

      def api_config
        @_api_config = Configuration.from_inherited_config api_model_configuration
        yield @_api_config
      end

    end
  end
end