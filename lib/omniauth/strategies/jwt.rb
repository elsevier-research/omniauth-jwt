require 'jwt'
require 'omniauth'
require 'typhoeus'
require 'byebug'

module OmniAuth
  module Strategies
    class JWT
      SITE_URL = 'https://loadrc-id.elsevier.com'

      include OmniAuth::Strategy

      option :callback_path, nil
      option :site, SITE_URL

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
        deep_symbolize(JSON.parse(get_info_call.response_body)) if get_info_call.response_code == 200
      end

      def get_info_call
        Typhoeus::Request.new("#{options.site}/idp/userinfo.openid",
                              method: :get,
                              verbose: true,
                              headers: {
                                Authorization: "Bearer #{request.params['jwt']}",
                                Accept: 'application/JSON',
                                'Content-Type' => 'application/JSON'
                              }).run
      end

      def callback_phase
        super
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
          policy_success:       raw_info[:policy_success],
          user_info_exp:        raw_info[:user_info_exp]
        }
      end
    end

    class Jwt < JWT; end
  end
end
