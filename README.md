# OmniAuth::JWT

[![Build Status](https://travis-ci.org/mbleigh/omniauth-jwt.png)](https://travis-ci.org/mbleigh/omniauth-jwt)

[JSON Web Token](http://self-issued.info/docs/draft-ietf-oauth-json-web-token.html) (JWT) is a simple
way to send verified information between two parties online. This can be useful as a mechanism for
providing Single Sign-On (SSO) to an application by allowing an authentication server to send a validated
claim and log the user in. This is how [Zendesk does SSO](https://support.zendesk.com/entries/23675367-Setting-up-single-sign-on-with-JWT-JSON-Web-Token-),
for example.

OmniAuth::JWT provides a clean, simple wrapper on top of JWT so that you can easily implement this kind
of SSO either between your own applications or allow third parties to delegate authentication.

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-jwt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-jwt

## Usage

You use OmniAuth::JWT just like you do any other OmniAuth strategy:

```ruby
use OmniAuth::Builder do
	provider :jwt, redirect_uri: "http://127.0.0.1:9292/auth/jwt/callback"
end
```

REQUIRED parameters:

* **token** this is the encoded token retrieved by signing in a user on idplus that will be used by the external authenticator to verify   that a user exists on idplus by using the [getUserInfoCall](https://confluence.cbsels.com/display/ID/Get+UserInfo+Call).
* **env:** this is the idplus environment for the [getUserInfoCall]. Can either be `rc`, `dev` or `prod`

### Authentication Process

When you authenticate through `omniauth-jwt` you can send users to `/auth/jwt?token=ENCODEDJWTGOESHERE&env=rc`.

You can use the example sinatra app in `example` folder to test the
authentication:

1. `cd` into the `example` folder
2. run `bundle` to install gems
3. start the application `shotgun --server=thin --port=9292 config.ru`

You can now visit `http://127.0.0.1:9292/auth/jwt?token=ENCODEDJWTGOESHERE&env=rc`

**PLEASE NOTE:**

To retrieve the encoded `token` you can authenticate
via [omniauth idplus](https://github.com/yortz/omniauth-idplus) strategy
and use the `credentials["token"]` value of the json response. Be sure to pass
as `env` parameter the SAME environment used to retrieve the token in the
[omniauth idplus](https://github.com/yortz/omniauth-idplus) strategy.

```
"credentials": {
  "token": "encoded_token",
  "refresh_token": "refresh_token",
  "expires_at": 1548777273,
  "expires": true
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
