module ApiModel
  class HttpResponse
    attr_accessor :success

    attr_accessor :code
    attr_accessor :headers
    attr_accessor :body

    alias_method :success?, :success
  end
end