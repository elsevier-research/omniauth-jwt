require 'jwt'
require 'omniauth'
require 'byebug'

module OmniAuth
  module Strategies
    class JWT
      class ClaimInvalid < StandardError; end

      include OmniAuth::Strategy

      option :callback_path, nil

      def request_phase
        redirect [callback_path, "?jwt=", request.params['token']].join
      end

      def deep_symbolize(hash)
        hash.inject({}) do |h, (k,v)|
          h[k.to_sym] = v.is_a?(Hash) ? deep_symbolize(v) : v
          h
        end
      end

      def raw_info
        @raw_info ||= deep_symbolize(::JWT.decode(request.params['jwt'], nil, false).first)
      end

      def callback_phase
        super
      rescue ClaimInvalid => e
        fail! :claim_invalid, e
      end

      uid { raw_info[:sub]  }

      info do
        raw_info
        {
          name:       raw_info[:name],
          email:      raw_info[:email],
          first_name: raw_info[:given_name],
          last_name:  raw_info[:family_name]
        }
      end

      extra do
        {
          inst_assoc_method:    raw_info[:inst_assoc_method],
          inst_acct_id:         raw_info[:inst_acct_id],
          inst_acct_name:       raw_info[:inst_acct_name],
          inst_assoc:           raw_info[:inst_assoc],
          path_choice:          raw_info[:path_choice],
          email_verified:       raw_info[:email_verified],
          updated_at:           raw_info[:updated_at],
          inst_acct_image:      raw_info[:inst_acct_image],
          indv_identity_method: raw_info[:indv_identity_method],
          indv_identity:        raw_info[:indv_identity],
          auth_token:           raw_info[:auth_token],
          aud:                  raw_info[:aud],
          jti:                  raw_info[:jti],
          iss:                  raw_info[:iss],
          iat:                  raw_info[:iat],
          exp:                  raw_info[:exp],
          policy_success:       raw_info[:policy_success]
        }
      end
    end

    class Jwt < JWT; end
  end
end
