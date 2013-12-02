module ApiModel
  class Configuration
    attr_accessor :host

    def initialize
      @host = ''
    end
  end

  module ConfigurationMethods
    extend ActiveSupport::Concern

    module ClassMethods

      def api_model_configuration
        @api_model_configuration || superclass.api_model_configuration
      rescue
        @api_model_configuration = Configuration.new
      end

      def api_model
        @api_model_configuration = Configuration.new
        yield @api_model_configuration
      end

    end
  end
end