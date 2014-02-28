$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "api-model"
  s.version     = "1.1.0"
  s.authors     = ["Damien Timewell"]
  s.email       = ["mail@damientimewell.com"]
  s.licenses    = ['MIT']
  s.homepage    = "https://github.com/iZettle/api-model"
  s.summary     = "A simple way of interacting with rest APIs"
  s.description = "API model is a simple wrapper for interacting with external APIs. It tries to make it very simple and easy to make API calls and map the responses into objects."

  s.add_dependency 'activesupport', '~> 4.0'
  s.add_dependency 'activemodel', '~> 4.0'
  s.add_dependency 'typhoeus', '~> 0.6'
  s.add_dependency 'hashie', '~> 2.0'

  s.add_development_dependency "rspec", '~> 2.14'
  s.add_development_dependency "pry", '~> 0.9'
  s.add_development_dependency "vcr", '2.8.0'
  s.add_development_dependency "webmock", "1.15.0"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
end
