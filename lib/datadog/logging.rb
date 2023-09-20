# frozen_string_literal: true

require_relative 'logging/version'
require_relative 'logging/railtie' if defined?(Rails::Railtie)
require_relative 'logging/logger'
require_relative 'logging/formatter/json_formatter'
