require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'vcr'

require 'api-model'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures'
  c.hook_into :webmock # or :fakeweb
end

RSpec.configure do |config|

  # Reset any config changes after each spec
  config.after(:each) do
    ApiModel::Base.api_model do |c|
      c.host = ""
    end
  end

end