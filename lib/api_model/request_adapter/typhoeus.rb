module ApiModel
  module RequestAdapter
    class Typhoeus < Base
      def run
        @request = ::Typhoeus::Request.new @http_request.full_path, request_options
        response_from_request @request.run
      end

      def response_from_request(response)
        ApiModel::HttpResponse.new.tap do |http_response|
          http_response.success = response.success?
          http_response.code = response.code
          http_response.headers = response.headers
          http_response.body = response.body
        end
      end

      def request_options
        options = {}
        options[:method] = @http_request.method
        options[:headers] = @http_request.request_options.headers if @http_request.request_options.headers
        options[:body] = @http_request.request_options.request_body if @http_request.request_options.request_body
        options[:params] = @http_request.request_options.query_params if @http_request.request_options.query_params
        options
      end

      def request_url
        @request.url
      end

      def request_headers
        @request.options[:headers]
      end

      def request_method
        @request.original_options[:method]
      end

      def request_body
        @request.original_options[:body]
      end
    end
  end
end