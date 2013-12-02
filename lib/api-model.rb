require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'
require 'hashie/trash'

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
    include Initializer
    include ConfigurationMethods
  end
end