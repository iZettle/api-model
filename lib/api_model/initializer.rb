module ApiModel
  module Initializer
    include ApiModel::Assignment
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :initialize
    end

    def initialize(values={})
      run_callbacks :initialize do
        update_attributes values
      end
    end

  end
end
