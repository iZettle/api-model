module ApiModel
  class Request
    include ApiModel::Initializer

    attr_accessor :path, :method, :options, :api_call

    def run
      self.api_call = Typhoeus.send method, path, options
    end

    def method
    	@method ||= :get
    end

    def options
    	@options ||= {}
    end

  end
end