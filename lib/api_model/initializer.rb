module ApiModel
  module Initializer

    def self.included(klass)
      klass.extend ActiveModel::Callbacks
      klass.define_model_callbacks :initialize
    end

    def initialize(values={})
      run_callbacks :initialize do
        update_attributes values
      end
    end

    def update_attributes(values={})
      return unless values.present?

      values.each do |key,value|
        begin
          public_send "#{key}=", value
        rescue
          Log.debug "Could not set #{key} on #{self.class.name}"
        end
      end
    end

  end
end