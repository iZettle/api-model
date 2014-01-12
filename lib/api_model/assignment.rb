module ApiModel
  module Assignment

    # Convenience method to change attributes on an instance en-masse using a hash. This is
    # useful for when an api response includes changed attributes and you want to update the current
    # instance with the changes.
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