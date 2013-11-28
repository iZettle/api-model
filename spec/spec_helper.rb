require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'vcr'

require 'api-model'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures'
  c.hook_into :webmock # or :fakeweb
end