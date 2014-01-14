require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'vcr'

require 'api-model'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures'
  c.hook_into :webmock # or :fakeweb
end

# Disable STDOUT logging during tests
ApiModel.send :remove_const, :Log
ApiModel::Log = Logger.new('/dev/null')

RSpec.configure do |config|

  # Reset any config changes after each spec
  config.after(:each) do
    ApiModel::Base.reset_api_configuration
  end

end