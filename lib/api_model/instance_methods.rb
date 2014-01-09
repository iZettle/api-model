module ApiModel
  module InstanceMethods
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :save, :successful_save, :unsuccessful_save
    end

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

    # Convenience method to change attributes on an instance en-masse using a hash. This is
    # useful for when an api response includes changed attributes and you want to update the current
    # instance with the changes.
    def update_attributes_from_hash(values={})
      return unless values.present?

      values.each do |key,value|
        begin
          public_send "#{key}=", value
        rescue
          Log.debug "Could not set #{key} on #{self.class.name}"
        end
      end
    end

    # Sends a request to the api to update a resource. If the response was successful, then it will
    # update the instance with any changes which the API has returned. If not, it will set ActiveModel
    # errors.
    #
    # The default request type is PUT, but you can override this by setting ++:request_method++ in the
    # options hash.
    #
    # It also includes 3 callbacks which you can hook onto; ++save++, which is the entire method, whether
    # the API request was successful or not, and ++successful_save++ and ++unsuccessful_save++ which are
    # triggered on successful or unsuccessful responses.
    def save(path, body=nil, options={})
      request_method = options.delete(:request_method) || :put

      run_callbacks :save do
        response = self.class.call_api_with_json request_method, path, body, options
        response_success = response.http_response.api_call.success?

        if response_success
          run_callbacks :successful_save do
            update_attributes_from_hash response.response_body
          end
        else
          run_callbacks :unsuccessful_save do
            set_errors_from_hash response.response_body["errors"]
          end
        end

        response_success
      end
    end

  end
end