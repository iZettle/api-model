module ApiModel
  module InstanceMethods
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :save, :successful_save, :unsuccessful_save, :initialize

      attr_writer :persisted

      def persisted
        @persisted || false
      end

      alias_method :persisted?, :persisted
    end

    def initialize(attributes = nil)
      run_callbacks :initialize do
        super attributes
      end
    end

    # Convenience method to handle error hashes and set them as ActiveModel errors on instances.
    # Using the `obj`, you can move the errors on to child classes if needed.
    def set_errors_from_hash(errors_hash, obj = self)
      return false unless errors_hash.is_a? Hash

      errors_hash.each do |field,messages|
        if messages.is_a?(Array)
          messages.each do |message|
            set_error_on_self_or_child field, message, obj
          end
        else
          set_error_on_self_or_child field, messages, obj
        end
      end
    end

    # If the field to apply errors to is another ApiModel instance, call ++set_errors_from_hash++ on it.
    # Otherwise, go ahead and treat it as a normal ActiveModel error on the current ++obj++ instance.
    def set_error_on_self_or_child(field, messages, obj = self)
      if obj.respond_to?(field.to_sym) && obj.send(field.to_sym).respond_to?(:set_error_on_self_or_child)
        obj.send(field.to_sym).set_errors_from_hash messages
      else
        obj.errors.add obj.class.real_attribute_name_for(field.to_sym), messages
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
    #
    # By default it uses the ++ApiModel::Builder::Hash++ builder rather than using the normal method of
    # using the class, or api config builders. This is to avoid building new objects from the response,
    # but can be easily overriden by passing in ++:builder++ in the options hash.
    def save(path, body=nil, options={})
      request_method = options.delete(:request_method) || :put
      errors_root = options.delete(:json_errors_root) || self.class.api_model_configuration.json_errors_root

      run_callbacks :save do
        response = self.class.call_api_with_json request_method, path, body, options.reverse_merge(builder: ApiModel::Builder::Hash.new)
        response_success = response.http_response.api_call.success?
        error_messages = response.fetch_from_body(errors_root)

        set_errors_from_hash error_messages if error_messages.present?

        if response_success
          run_callbacks :successful_save do
            update_attributes response.response_build_hash
          end
        else
          run_callbacks :unsuccessful_save
        end

        response_success
      end
    end

  end
end
