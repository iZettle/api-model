require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'logger'

require 'api_model/initializer'
require 'api_model/request'

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
  end
end