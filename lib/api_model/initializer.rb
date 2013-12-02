module ApiModel
  module Initializer

    def initialize(values={})
      update_attributes values
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