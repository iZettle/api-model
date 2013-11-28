module ApiModel
  class HttpRequest
    include ApiModel::Initializer

    attr_accessor :path, :method, :options, :api_call

    def self.api_host=(api_host)
      @api_host = api_host
    end

    def self.api_host
      @api_host || ""
    end

    def self.run(options={})
      self.new(options).run
    end

    def run
      self.api_call = Typhoeus.send(method, full_path, options)
      Response.new self.api_call
    end

    def method
      @method ||= :get
    end

    def options
      @options ||= {}
    end

    def full_path
      return path if path =~ /^http/
      self.class.api_host + path
    end

  end
end