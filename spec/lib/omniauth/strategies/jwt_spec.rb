require 'spec_helper'

describe OmniAuth::Strategies::JWT do
  let(:response_json){ JSON.load(last_response.body) }

  let(:app){
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, secret: 'sekrit'
      b.use OmniAuth::Strategies::JWT
      b.run -> (env) { [ 200, {}, [ (env['omniauth.auth'] || {}).to_json ] ] }
    end
  }

  let(:token) do
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

  context 'request phase' do
    it 'should redirect to default callback path' do
      get '/auth/jwt'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq('/auth/jwt/callback?jwt=')
    end
  end

  context 'callback phase' do
    it 'should decode the response' do
      encoded = JWT.encode(token, false, "none")
      get '/auth/jwt/callback?jwt=' + encoded
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

    it 'should assign the uid' do
      encoded = JWT.encode({name: 'Steve', email: 'dude@awesome.com'}, false, "none")
      get '/auth/jwt/callback?jwt=' + encoded
      expect(response_json["uid"]).to eq('dude@awesome.com')
    end

    context 'with a :valid_within option set' do
      let(:args){ ['imasecret', {auth_url: 'http://example.com/login', valid_within: 300}] }

      it 'should work if the iat key is within the time window' do
        encoded = JWT.encode({name: 'Ted', email: 'ted@example.com', iat: Time.now.to_i}, 'imasecret')
        get '/auth/jwt/callback?jwt=' + encoded
        expect(last_response.status).to eq(200)
      end

      it 'should not work if the iat key is outside the time window' do
        encoded = JWT.encode({name: 'Ted', email: 'ted@example.com', iat: Time.now.to_i + 500}, 'imasecret')
        get '/auth/jwt/callback?jwt=' + encoded
        expect(last_response.status).to eq(302)
      end

      it 'should not work if the iat key is missing' do
        encoded = JWT.encode({name: 'Ted', email: 'ted@example.com'}, 'imasecret')
        get '/auth/jwt/callback?jwt=' + encoded
        expect(last_response.status).to eq(302)
      end
    end
  end
end
