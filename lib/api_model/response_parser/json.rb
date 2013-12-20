module ApiModel
  module ResponseParser
    class Json

      def parse(body)
        JSON.parse body
      rescue JSON::ParserError
        Log.info "Could not parse JSON response: #{body}"
        return nil
      end

    end
  end
end