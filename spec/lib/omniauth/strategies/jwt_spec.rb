require 'spec_helper'

describe OmniAuth::Strategies::JWT do
  let(:app) do
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, secret: 'sekrit'
      b.use OmniAuth::Strategies::JWT
      b.run -> (env) { [ 200, {}, [ (env['omniauth.auth'] || {}).to_json ] ] }
    end
  end

  subject do
    OmniAuth::Strategies::JWT.new(app, @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) { request }
    end
  end

  it 'has a version number' do
    expect(Omniauth::JWT::VERSION).not_to be nil
  end

  describe 'options' do
    it 'defaults redirect_urit to nil' do
      @options = {}
      expect(subject.options.redirect_uri).to eq(nil)
    end

    it 'overrides the redirect_uri' do
      @options = { redirect_uri: 'https://example.com/auth/idplus/callback' }
      expect(subject.options.redirect_uri).to eq('https://example.com/auth/idplus/callback')
    end
  end

  context 'request phase' do
    it 'should redirect to default callback path' do
      get '/auth/jwt', jwt: "encodedtoken", env: 'rc'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq('/auth/jwt/callback?jwt=')
    end
  end

  context 'callback phase' do
    before do
      OmniAuth.config.test_mode = true
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    after { OmniAuth.config.test_mode = false }

    let(:raw_info_hash) do
      {
          "sub": "123456",
          "inst_acct_name": "Hivebench Maintenance Staff",
          "email_verified": true,
          "user_info_exp": "1548082214",
          "inst_acct_image": "http://loadrc-id.elsevier.com/assets/images/elsevier/default_institution.JPG",
          "inst_acct_id": "123456",
          "given_name": "Ferris",
          "inst_assoc_method": "CSCREATED",
          "policy_success": [
              "urn:com:elsevier:idp:policy:product:indv_identity",
              "urn:com:elsevier:idp:policy:product:inst_assoc"
          ],
          "path_choice": false,
          "updated_at": 1544870419,
          "indv_identity_method": "U_P",
          "indv_identity": "REG",
          "inst_assoc": "INST",
          "name": "Ferris Bueller",
          "auth_token": "a3a777d5353d374cd359c9752ac4b743baa1gxrqb",
          "family_name": "Bueller",
          "email": "ferris.bueller@email.com"
      }
    end

    it 'responds with valid json' do
      get '/auth/jwt/callback',  jwt: 'encodedtoken', env: 'rc'
      expect(subject.uid).to eq("123456")
      expect(subject.info[:name]).to eq("Ferris Bueller")
      expect(subject.info[:email]).to eq("ferris.bueller@email.com")
      expect(subject.info[:first_name]).to eq("Ferris")
      expect(subject.info[:last_name]).to eq("Bueller")
      expect(subject.extra[:inst_assoc_method]).to eq("CSCREATED")
      expect(subject.extra[:inst_acct_id]).to eq("123456")
      expect(subject.extra[:inst_acct_name]).to eq("Hivebench Maintenance Staff")
      expect(subject.extra[:inst_assoc]).to eq("INST")
      expect(subject.extra[:path_choice]).to eq(false)
      expect(subject.extra[:email_verified]).to eq(true)
      expect(subject.extra[:user_info_exp]).to eq("1548082214")
      expect(subject.extra[:updated_at]).to eq(1544870419)
      expect(subject.extra[:inst_acct_image]).to eq("http://loadrc-id.elsevier.com/assets/images/elsevier/default_institution.JPG")
      expect(subject.extra[:indv_identity_method]).to eq("U_P")
      expect(subject.extra[:indv_identity]).to eq("REG")
      expect(subject.extra[:auth_token]).to eq("a3a777d5353d374cd359c9752ac4b743baa1gxrqb")
      expect(subject.extra[:policy_success]).to eq([ "urn:com:elsevier:idp:policy:product:indv_identity", "urn:com:elsevier:idp:policy:product:inst_assoc" ])
    end
  end
end
