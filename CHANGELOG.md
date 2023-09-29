## [Unreleased]

## [0.1.0.2] - 2023-09-29

- Define method 'log_rescued_responses?' for `Datadog::Logging::Middleware::LogExceptions` for Rails versions < to 7.0
- Wrap method 'rescue_response?' for `Datadog::Logging::Middleware::LogExceptions` for Rails versions < to 7.0

## [0.1.0.1] - 2023-09-25

- Fix undefined method 'empty?' for nil:NilClass `Datadog::Logging::Logger#parsed_response`

## [0.1.0] - 2023-09-20

- Initial release
  - Add `Datadog::Logging::Logger#http_request` and `Datadog::Logging::Logger::UserFormatter`
  - Add `Datadog::Logging::Formatter::JsonFormatter`
  - Add `Datadog::Logging::Middleware::LogExceptions`
  - Add `Datadog::Logging::Railtie`
