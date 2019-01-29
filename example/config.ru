require 'rubygems'
require 'bundler'
require 'sinatra'
require '../lib/omniauth/strategies/jwt'
require 'json'

class JWTApp < Sinatra::Base
  post '/' do
    <<-HTML
      <p><a href="/auth/idplus">Sign into Id +</a></p>
    HTML
  end

  get '/auth/:provider/callback' do |provider|
    content_type :json
    begin
      %( #{provider} token: #{request.env['omniauth.auth'].to_json}
          )
    rescue StandardError
      'No data returned'
    end
  end

  get '/auth/failure' do
    content_type 'text/plain'
    begin
      %( Error: #{request.env['omniauth.auth'].to_hash.inspect}
          )
    rescue StandardError
      'No data returned'
    end
  end
end

use Rack::Session::Cookie, secret: 'abc'

use OmniAuth::Builder do
  provider :jwt, redirect_uri: 'http://127.0.0.1:9292/auth/jwt/callback'
end

run JWTApp.new

# shotgun --server=thin --port=9292 examples/config.ru
