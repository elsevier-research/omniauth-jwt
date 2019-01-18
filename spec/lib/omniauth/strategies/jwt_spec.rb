require 'spec_helper'

describe OmniAuth::Strategies::JWT do
  let(:response_json){ JSON.load(last_response.body) }

  let(:app) do
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, secret: 'sekrit'
      b.use OmniAuth::Strategies::JWT
      b.run -> (env) { [ 200, {}, [ (env['omniauth.auth'] || {}).to_json ] ] }
    end
  end

  let(:payload) do
    {
      sub:                  "123456",
      name:                 "Ferris",
      email:                "f.bueller@email.com",
      given_name:           "Ferris",
      family_name:          "Bueller",
      inst_assoc_method:    "IP",
      inst_acct_id:         "123",
      inst_acct_name:       "Elsevier Account",
      inst_assoc:           "INST",
      path_choice:          false,
      email_verified:       true,
      updated_at:           1532364535,
      inst_acct_image:      "http://id.elsevier.com/assets/images/elsevier/default_institution.JPG",
      indv_identity_method: "U_P",
      indv_identity:        "REG",
      auth_token:           "9ab392ba3d04694abc1b7c19002ac1030412gxrqa",
      aud:                  "HIVEBENCH-dev",
      jti:                  "I5OnC4GpqfhiCSYJ9Jpz57",
      iss:                  "https://id.elsevier.com",
      iat:                  1540993786,
      exp:                  1540994086,
      policy_success:       [ "urn:com:elsevier:idp:policy:product:indv_identity", "urn:com:elsevier:idp:policy:product:inst_assoc" ]
    }
  end

  let(:id_token) do
    JWT.encode payload, false, "none"
  end

  let(:token_exchange_call) do
    # this is the response of the token exchange call
    # used by native apps to decode the JWt token from
    # the user currently signed in on idplus
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsImtpZCI6IklEUExVU0FDQ1RPS0VOIn0.eyJzY29wZSI6WyJvcGVuaWQiLCJlbWFpbCIsInByb2ZpbGUiLCJlbHNfYXV0aF9pbmZvIiwidXJuOmNvbTplbHNldmllcjppZHA6cG9saWN5OnByb2R1Y3Q6aW5kdl9pZGVudGl0eSJdLCJjbGllbnRfaWQiOiJISVZFQkVOQ0gtZGV2IiwiYWNjZXNzR3JhbnRHdWlkIjoiaWtyTHY2ZVhHTTRRSk9FZHl1WUNFZ0VXQjlZV2VLbGQiLCJwbGF0U2l0ZSI6IkhJVi9oaXZlIiwic3ViamVjdCI6IjMxNjMyNzMzIiwiYXV0aFRva2VuIjoiOTZkZTM2NmY4YmI2MjI0MWRlMzg1NDM2NzRjYjgyYTBhNGExZ3hycWIiLCJvYXV0aFNjb3BlIjpbIm9wZW5pZCIsImVtYWlsIiwicHJvZmlsZSIsImVsc19hdXRoX2luZm8iLCJ1cm46Y29tOmVsc2V2aWVyOmlkcDpwb2xpY3k6cHJvZHVjdDppbmR2X2lkZW50aXR5Il0sImF1dGhUeXBlIjoiSElWL2hpdmUiLCJleHAiOjE1NDUwNTQ1NTF9.S_k4My4UXjNPm9-wlP4V7EGQ6tXqmcAXKvFEiQQjCnQ",
        "refresh_token": "bJ7WWLSkDJF9qP2u2RELBYsRJw14p7OBYLeVQ9gQr2",
        "id_token": id_token,
        "token_type": "Bearer",
        "expires_in": 7199
    }
  end

  context 'request phase' do
    it 'should redirect to default callback path' do
      get '/auth/jwt', params: { token: token_exchange_call[:id_token] }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq('/auth/jwt/callback?jwt=')
    end
  end

  context 'callback phase' do
    it 'should decode the encoded token passed as param' do
      get '/auth/jwt/callback',  jwt: id_token
      expect(response_json["uid"]).to eq("123456")
      expect(response_json["info"]["name"]).to eq("Ferris")
      expect(response_json["info"]["email"]).to eq("f.bueller@email.com")
      expect(response_json["info"]["first_name"]).to eq("Ferris")
      expect(response_json["info"]["last_name"]).to eq("Bueller")
      expect(response_json["extra"]["inst_assoc_method"]).to eq("IP")
      expect(response_json["extra"]["inst_acct_id"]).to eq("123")
      expect(response_json["extra"]["inst_acct_name"]).to eq("Elsevier Account")
      expect(response_json["extra"]["inst_assoc"]).to eq("INST")
      expect(response_json["extra"]["path_choice"]).to eq(false)
      expect(response_json["extra"]["email_verified"]).to eq(true)
      expect(response_json["extra"]["updated_at"]).to eq(1532364535)
      expect(response_json["extra"]["inst_acct_image"]).to eq("http://id.elsevier.com/assets/images/elsevier/default_institution.JPG")
      expect(response_json["extra"]["indv_identity_method"]).to eq("U_P")
      expect(response_json["extra"]["indv_identity"]).to eq("REG")
      expect(response_json["extra"]["auth_token"]).to eq("9ab392ba3d04694abc1b7c19002ac1030412gxrqa")
      expect(response_json["extra"]["aud"]).to eq("HIVEBENCH-dev")
      expect(response_json["extra"]["jti"]).to eq("I5OnC4GpqfhiCSYJ9Jpz57")
      expect(response_json["extra"]["iss"]).to eq("https://id.elsevier.com")
      expect(response_json["extra"]["iat"]).to eq(1540993786)
      expect(response_json["extra"]["exp"]).to eq(1540994086)
      expect(response_json["extra"]["policy_success"]).to eq([ "urn:com:elsevier:idp:policy:product:indv_identity", "urn:com:elsevier:idp:policy:product:inst_assoc" ])
    end
  end
end
