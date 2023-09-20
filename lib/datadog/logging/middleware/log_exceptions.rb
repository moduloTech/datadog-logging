# frozen_string_literal: true

module Datadog

  module Logging

    module Middleware

      class LogExceptions < ActionDispatch::DebugExceptions

        private

        def log_error(request, wrapper)
          logger = logger(request)

          return unless logger
          return if !log_rescued_responses?(request) && wrapper.rescue_response?

          exception = wrapper.exception

          logger.fatal({
                         error: {
                           kind: exception.class.name, message: exception.message, stack: exception.backtrace
                         }
                       })
        end

      end

    end

  end

end
