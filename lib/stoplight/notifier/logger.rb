# frozen_string_literal: true

module Stoplight
  module Notifier
    # @see Base
    class Logger < Base
      include Generic

      # @return [::Logger]
      def logger
        @object
      end

      def put(message)
        logger.warn(message)
      end
    end
  end
end
