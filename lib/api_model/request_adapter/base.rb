module ApiModel
  module RequestAdapter
    class Base
      def initialize(http_request)
        @http_request = http_request
      end

      def request_url
        raise NotImplementedException
      end

      def request_headers
        raise NotImplementedException
      end

      def request_method
        raise NotImplementedException
      end

      def request_body
        raise NotImplementedException
      end
    end

    class NotImplementedException < Exception; end
  end
end