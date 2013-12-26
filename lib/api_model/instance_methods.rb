module ApiModel
  module InstanceMethods

    # Overrides Hashie::Trash to catch errors from trying to set properties which have not been defined
    # and defines it automatically
    def property_exists?(property_name)
      super property_name
    rescue NoMethodError
      Log.debug "Could not set #{property_name} on #{self.class.name}. Defining it now."
      self.class.property property_name.to_sym
    end

    # Convenience method to handle error hashes and set them as ActiveModel errors on instances.
    # Using the `obj`, you can move the errors on to child classes if needed.
    def set_errors_from_hash(errors_hash, obj = self)
      errors_hash.each do |field,messages|
        if messages.is_a?(Array)
          messages.each do |message|
            obj.errors.add field.to_sym, message
          end
        else
          obj.errors.add field.to_sym, messages
        end
      end
    end

  end
end