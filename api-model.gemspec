$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "api-model"
  s.version     = "0.0.1"
  s.authors     = ["Damien Timewell"]
  s.email       = ["mail@damientimewell.com"]
  s.homepage    = "https://github.com/iZettle/api-model"
  s.summary     = "A simple way of interacting with rest APIs"
  s.description = "A simple way of interacting with rest APIs"

  # s.add_dependency 'redis'
  s.add_dependency 'activesupport'
  s.add_dependency 'activemodel'
  s.add_dependency 'typhoeus'

  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock", "1.15.0"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
end
