module ApiModel
  class ErrorMessageFormatter

    def self.format(http_response)
      "#{http_response.api_call.response_code}: #{http_response.api_call.request.url}"
    end

  end
end
