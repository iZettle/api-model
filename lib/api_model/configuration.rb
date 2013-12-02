module ApiModel
  module ConfigurationMethods
    attr_writer :api_model_configuration

    def api_model_configuration
      @api_model_configuration ||= Configuration.new
    end

    def api_model
      yield api_model_configuration
    end
  end

  class Configuration
    attr_accessor :host

    def initialize
      @host = ''
    end
  end
end