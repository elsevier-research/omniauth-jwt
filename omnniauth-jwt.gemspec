# frozen_string_literal: true

require 'English'
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/jwt/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-jwt'
  spec.version       = Omniauth::JWT::VERSION
  spec.authors       = ['Michael Bleigh', 'Robin Ward']
  spec.email         = ['mbleigh@mbleigh.com', 'robin.ward@gmail.com']
  spec.description   = 'An OmniAuth strategy to accept JWT-based single sign-on.'
  spec.summary       = 'An OmniAuth strategy to accept JWT-based single sign-on.'
  spec.homepage      = 'http://github.com/yortz/omniauth-jwt'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2.2'
  spec.add_development_dependency 'bundler', '~> 2.4.12'
  spec.add_development_dependency 'byebug', '~> 11.1.3'
  spec.add_development_dependency 'guard', '~> 2.18.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'rack-test', '~> 2.1.0'
  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.12.0'

  spec.add_dependency 'httparty', '~> 0.21.0'
  spec.add_dependency 'jwt', '~> 2.7.0'
  spec.add_dependency 'omniauth', '~> 2.1.1'
end
