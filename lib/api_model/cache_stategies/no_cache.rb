module ApiModel
  module CacheStrategies
    class NoCache

      def initialize(*args)
      end

      def cache(&block)
        yield
      end

    end
  end
end