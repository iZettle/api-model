module ApiModel
  module Builder
    class Hash

      def build(response)
        response if response.is_a?(Hash)
      end

    end
  end
end