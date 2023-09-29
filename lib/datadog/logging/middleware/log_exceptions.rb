# frozen_string_literal: true

module Datadog

  module Logging

    module Middleware

      class LogExceptions < ActionDispatch::DebugExceptions

        private

        def log_error(request, wrapper)
          logger = logger(request)

          return unless logger
          return if !log_rescued_responses?(request) && rescue_response?(wrapper)

          exception = wrapper.exception

          logger.fatal({
                         error: {
                           kind: exception.class.name, message: exception.message, stack: exception.backtrace
                         }
                       })
        end

        def rescue_response?(wrapper)
          if wrapper.respond_to?(:rescue_response?)
            # From Rails 7.0
            wrapper.rescue_response?
          else
            # Before Rails 7.0
            wrapper.rescue_responses.key?(wrapper.exception.class.name)
          end
        end

        # Starting with Rails 7.0, method is defined.
        unless method_defined?(:log_rescued_responses?)
          def log_rescued_responses?(request)
            request.get_header('action_dispatch.log_rescued_responses')
          end
        end

      end

    end

  end

end
