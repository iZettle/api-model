module ApiModel
  class Configuration
    attr_accessor :host

    def initialize
      @host = ''
    end
  end

  module ConfigurationMethods
    extend ActiveSupport::Concern

    included do
      mattr_accessor :api_model_configuration, instance_writer: false
      self.api_model_configuration = Configuration.new
    end

    module ClassMethods

      def api_model
        yield api_model_configuration
      end

    end
  end
end