require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'

require 'api_model/initializer'
require 'api_model/http_request'
require 'api_model/response'

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

    def self.api_host=(api_host)
      @api_host = api_host
    end

    def self.api_host
      @api_host || ""
    end

    def self.get_json(path, options={})
      # TODO - tidy this up...
      builder = options.delete(:builder) || self
      options[:api_host] = api_host

      HttpRequest.run(options.merge(path: path)).build_objects builder
    end

  end
end