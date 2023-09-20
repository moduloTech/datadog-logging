# frozen_string_literal: true

require_relative 'middleware/log_exceptions'

module Datadog

  module Logging

    class Railtie < ::Rails::Railtie

      # Update and add gems before we load the configuration
      config.before_configuration do
        Rails.configuration.middleware.insert_after(ActionDispatch::DebugExceptions, Middleware::LogExceptions)
        Rails.configuration.log_formatter = Formatter::JsonFormatter
      end

    end

  end

end
