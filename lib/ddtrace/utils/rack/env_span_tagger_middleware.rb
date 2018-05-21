require 'ddtrace/utils/mass_tagger'

module Datadog
  module Utils
    module Rack
      class EnvSpanTaggerMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          span = request_span!(env)
          Datadog::Utils::MassTagger.tag(span, request_headers_whitelist, Datadog::Utils::MassTagger::RackRequest, env)
          _, headers, = @app.call(env)
        ensure
          Datadog::Utils::MassTagger.tag(span, response_headers_whitelist, Datadog::Utils::MassTagger::RackResponse, headers)
        end

        protected

        def configuration
          raise NotImplementedError
        end

        def build_request_span(_env)
          raise NotImplementedError
        end

        def env_request_span
          raise NotImplementedError
        end

        def request_headers_whitelist
          configuration[:headers][:request]
        end

        def response_headers_whitelist
          configuration[:headers][:response]
        end

        def request_span!(env)
          env[env_request_span] ||= build_request_span(env)
        end
      end
    end
  end
end