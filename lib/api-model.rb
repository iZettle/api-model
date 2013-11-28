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

    def self.get_json(path, options={})
      builder = options.delete(:builder) || self
      HttpRequest.run(options.merge(path: path)).build_objects builder
    end

  end
end