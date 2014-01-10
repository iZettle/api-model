require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'
require 'hashie'
require 'typhoeus'
require 'ostruct'

require 'api_model/initializer'
require 'api_model/http_request'
require 'api_model/response'
require 'api_model/class_methods'
require 'api_model/instance_methods'
require 'api_model/configuration'
require 'api_model/cache_stategy/no_cache'
require 'api_model/response_parser/json'
require 'api_model/builder/hash'

module ApiModel
  Log = Logger.new STDOUT

  class ResponseBuilderError < StandardError; end
  class UnauthenticatedError < StandardError; end
  class NotFoundError < StandardError; end

  if defined?(Rails)
    class Railtie < Rails::Railtie
      initializer "api-model" do
        ApiModel.send :remove_const, :Log
        ApiModel::Log = Rails.logger
      end
    end
  end

  class Base < Hashie::Trash
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Serialization
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    extend ClassMethods
    include ConfigurationMethods
    include InstanceMethods
  end

end