require 'spec_helper'

describe ApiModel::Request do

	describe "default attributes" do
		subject { ApiModel::Request.new }

		it "should default #method to :get" do
			subject.method.should eq :get
		end

		it "should default #options to a blank hash" do
			subject.options.should eq Hash.new
		end
	end

  let(:request) { ApiModel::Request.new path: "http://api-model-specs.com/posts", method: :get }

  it "should use typhoeus to send a request" do
    VCR.use_cassette('posts') do
      request.run
    end

    request.api_call.success?.should eq true
  end

end