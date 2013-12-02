require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'
require 'hashie'

require 'api_model/initializer'
require 'api_model/http_request'
require 'api_model/response'
require 'api_model/rest_methods'
require 'api_model/configuration'

module ApiModel

  if defined? Rails
    Log = Rails.logger
  else
    Log = Logger.new STDOUT
  end

  class Base < Hashie::Trash
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Serialization
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    extend RestMethods
    include ConfigurationMethods

    # Overrides Hashie::Trash to catch errors from trying to set properties which have not been defined.
    # It would be nice to handle this in a cleaner way. Perhaps even automatically define the properties.
    def property_exists?(property)
      super property
    rescue NoMethodError
      puts "Could not set #{property} on #{self.class.name}"
    end
  end

end