# frozen_string_literal: true

require 'jwt'
require 'omniauth'
require 'httparty'

module OmniAuth
  module Strategies
    # JWT Strategy
    class JWT
      class InvalidResponse < StandardError; end

      include OmniAuth::Strategy

      option :callback_path, nil

      def request_phase
        redirect [callback_path, '?jwt=', request.params['token'], '&env=', request.params['env']].join
      end

      def deep_symbolize(hash)
        hash.each_with_object({}) do |(k, v), h|
          h[k.to_sym] = v.is_a?(Hash) ? deep_symbolize(v) : v
        end
      end

      def environment
        case request.params['env'] # rubocop:disable Style/HashLikeCase
        when 'rc'   then  'https://loadrc-id.elsevier.com'
        when 'dev'  then  'https://loadcq-id.elsevier.com'
        when 'prod' then  'https://id.elsevier.com'
        end
      end

      def raw_info
        @response ||= get_info_call
        case @response.code
        when 400, 401
          raise InvalidResponse, @response.code
        else
          @decoded ||= deep_symbolize(JSON.parse(@response.body))
        end
      end

      def get_info_call # rubocop:disable Naming/AccessorMethodName
        puts request.params['jwt']
        HTTParty.get([environment, 'idp/userinfo.openid'].join('/'),
                     headers: {
                       Authorization: "Bearer #{request.params['jwt']}",
                       Accept: 'application/JSON',
                       'Content-Type' => 'application/JSON'
                     })
      end

      def callback_phase
        super
      rescue InvalidResponse => e
        fail! :unauthorized, e
      end

      uid { raw_info[:sub] }

      info do
        {
          name: raw_info[:name],
          email: raw_info[:email],
          first_name: raw_info[:given_name],
          last_name: raw_info[:family_name]
        }
      end

      extra do
        {
          inst_assoc_method: raw_info[:inst_assoc_method],
          inst_acct_id: raw_info[:inst_acct_id],
          inst_acct_name: raw_info[:inst_acct_name],
          inst_assoc: raw_info[:inst_assoc],
          path_choice: raw_info[:path_choice],
          email_verified: raw_info[:email_verified],
          updated_at: raw_info[:updated_at],
          inst_acct_image: raw_info[:inst_acct_image],
          indv_identity_method: raw_info[:indv_identity_method],
          indv_identity: raw_info[:indv_identity],
          auth_token: raw_info[:auth_token],
          policy_success: raw_info[:policy_success],
          user_info_exp: raw_info[:user_info_exp]
        }
      end
    end

    class Jwt < JWT; end
  end
end
