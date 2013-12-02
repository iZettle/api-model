require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'

require 'api_model/configuration'
require 'api_model/initializer'
require 'api_model/http_request'
require 'api_model/response'
require 'api_model/rest_methods'

module ApiModel

  if defined? Rails
    Log = Rails.logger
  else
    Log = Logger.new STDOUT
  end

  class Base
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    include ApiModel::Initializer
    extend ApiModel::RestMethods

    class << self
      attr_writer :api_model_configuration

      def api_model_configuration
        @api_model_configuration ||= Configuration.new
      end

      def configure_api_model
        yield api_model_configuration
      end
    end

    class Configuration
      attr_accessor :api_host

      def initialize
        @api_host = ''
      end
    end

  end
end