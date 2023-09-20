# frozen_string_literal: true

module Datadog

  module Logging

    module Formatter

      class JsonFormatter

        # @param [String] severity The Severity of the log message: should correspond to a constant in Logger::Severity
        # @param [Object] time A Time instance representing when the message was logged.
        # @param [Object] progname The #progname configured, or passed to the logger method.
        # @param [Object] msg The _Object_ the user passed to the log message; not necessarily a String.
        # @return [String (frozen)]
        # @see Logger::Severity
        def self.call(severity, time, progname, msg)
          new.call(severity, time, progname, msg)
        end

        # @param [String] _severity The Severity of the log message: should correspond to a constant in Logger::Severity
        # @param [Object] time A Time instance representing when the message was logged.
        # @param [Object] progname The #progname configured, or passed to the logger method.
        # @param [Object] msg The _Object_ the user passed to the log message; not necessarily a String.
        # @return [String (frozen)]
        # @see Logger::Severity
        def call(_severity, time, progname, msg)
          base_message = { time: time }

          base_message[:progname] = progname unless progname.nil? || progname.empty?

          message = case msg
                    when String
                      base_message.merge(message: msg)
                    when Exception
                      base_message.merge(error: {
                                           kind: msg.class.name, message: msg.message, stack: msg.backtrace
                                         })
                    when Hash
                      base_message.merge(msg)
                    else
                      base_message.merge(message: msg.inspect)
                    end

          "#{message.to_json}\n"
        end

      end

    end

  end

end
