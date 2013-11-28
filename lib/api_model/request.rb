module ApiModel
  class Request
    include ApiModel::Initializer

    attr_accessor :path, :method, :options, :api_call, :body

    def run
      self.api_call = Typhoeus.send method, path
    end

  end
end