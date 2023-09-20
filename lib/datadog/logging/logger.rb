# frozen_string_literal: true

module Datadog

  module Logging

    class Logger

      class UserFormatter

        attr_reader :user

        def initialize(user)
          @user = user
        end

        def call
          base = {
            id:       id,
            username: username,
            email:    email,
            role:     role
          }

          result = base.compact

          result.empty? ? nil : result
        end

        def self.call(user)
          new(user).call
        end

        private

        ID_KEYS = ['id', 'user_id', :id, :user_id].freeze
        USERNAME_KEYS = ['name', 'username', :name, :username].freeze
        EMAIL_KEYS = ['email', 'mail', :email, :mail].freeze
        ROLE_KEYS = [
          'role', 'roles', 'user_role', 'user_roles', 'userrole', 'userroles',
          :role, :roles, :user_role, :user_roles, :userrole, :userroles
        ].freeze

        %w[id username email role].each do |field|
          define_method(field) do
            keys = self.class.const_get("#{field.upcase}_KEYS")

            case user
            when nil
              nil
            when Hash
              key = keys.find { |key| user[key] }

              key.nil? ? nil : user[key]
            else
              key = keys.find { |key| user.respond_to?(key) }

              key.nil? ? nil : user.public_send(key)
            end
          end
        end

      end

      attr_accessor :logger
      attr_accessor :user_formatter

      def initialize(logger, log_level: :info, user_formatter: UserFormatter)
        @logger = logger
        @log_level = validate_log_level(log_level)
        @user_formatter = user_formatter || UserFormatter
      end

      # rubocop:disable Metrics/ParameterLists
      def http_request(method:, path:, controller:, action:, response:, headers: {}, params: {},
                       request_id: SecureRandom.uuid, user: nil)
        logger.send(@log_level, {
                      method:     method.to_s.upcase,
                      path:       path,
                      format:     headers['Accept'] || '*/*',
                      controller: controller,
                      action:     action,
                      status:     response.code,
                      request_id: request_id,
                      headers:    headers,
                      params:     parsed_params(params, headers),
                      response:   parsed_response(response),
                      user:       format_user(user)
                    })
      end
      # rubocop:enable Metrics/ParameterLists

      private

      def validate_log_level(level)
        ::Logger::Severity.constants.include?(level.to_s.upcase.to_sym) ? level : :info
      end

      def parsed_params(params, headers)
        # If body is JSON, we want to get it as Hash
        if headers['Content-Type'] == 'application/json'
          JSON.parse(params)
        else
          params
        end
      end

      def parsed_response(response)
        return nil if response.body.empty?

        # If response is JSON, we want to get it as Hash
        if response.header['Content-Type']&.match(%r{application/json})
          begin
            JSON.parse(response.body)
          rescue StandardError
            nil
          end
        else
          response.body
        end
      end

      def format_user(user)
        @user_formatter.call(user)
      end

    end

  end

end
