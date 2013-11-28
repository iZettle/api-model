require 'active_model'
require 'active_support'
require 'active_support/core_ext'

require 'api_model/initializer'
require 'api_model/request'

module ApiModel
  class Base
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    include ApiModel::Initializer
  end
end