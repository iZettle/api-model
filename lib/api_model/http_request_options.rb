module ApiModel
  class HttpRequestOptions
    attr_accessor :headers
    attr_accessor :request_body
    attr_accessor :query_params

    def initialize(options_hash)
      self.headers = options_hash[:headers]
      self.query_params = options_hash[:params]
      self.request_body = options_hash[:body]
    end
  end
end