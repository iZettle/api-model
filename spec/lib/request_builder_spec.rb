require 'spec_helper'

describe ApiModel::Request do

  let(:request) { ApiModel::Request.new path: "http://api-model-specs.com/posts", method: :get }

  it "should use typhoeus to send a request" do
    VCR.use_cassette('posts') do
      request.run
    end

    request.api_call.success?.should eq true
  end

end