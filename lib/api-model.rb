require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'
require 'hashie'
require 'ostruct'

require 'api_model/initializer'
require 'api_model/http_request'
require 'api_model/response'
require 'api_model/rest_methods'
require 'api_model/configuration'
require 'api_model/cache_stategies/no_cache'
require 'api_model/response_parser/json'

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

    extend RestMethods
    include ConfigurationMethods

    # Overrides Hashie::Trash to catch errors from trying to set properties which have not been defined
    # and defines it automatically
    def property_exists?(property_name)
      super property_name
    rescue NoMethodError
      Log.debug "Could not set #{property_name} on #{self.class.name}. Defining it now."
      self.class.property property_name.to_sym
    end
  end

end