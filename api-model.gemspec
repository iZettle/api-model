$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "api-model"
  s.version     = "0.0.1"
  s.authors     = ["Damien Timewell"]
  s.email       = ["mail@damientimewell.com"]
  s.homepage    = "https://github.com/idlefingers/api-model"
  s.summary     = "A simple way of interacting with rest APIs"
  s.description = "A simple way of interacting with rest APIs"

  s.add_dependency 'redis'
  s.add_dependency 'rails'

  s.files = `git ls-files`.split("\n")
end
