require 'spec_helper'
require 'support/mock_models/blog_post'

describe "Parsing" do

  after :each do
    BlogPost.reset_api_configuration
  end

  describe "Default parser" do
    it "should produce a hash given valid json" do
      ApiModel::ResponseParser::Json.new.parse("{\"name\":\"foo\"}")["name"].should eq "foo"
    end

    it "should catch errors from parsing invalid json" do
      ApiModel::Log.should_receive(:info).with "Could not parse JSON response: blah"

      expect {
        ApiModel::ResponseParser::Json.new.parse("blah")
      }.to_not raise_error
    end
  end

  describe "Parser with response handling" do
    class CustomResponseParser
      def parse(response, body)
        response.metadata.foobar = "Baz"
        { name: "A blog post" }
      end
    end

    before do
      BlogPost.api_config do |config|
        config.parser = CustomResponseParser.new
      end
    end

    it "should use the response object" do
      VCR.use_cassette('posts') do
        res = BlogPost.get_json "http://api-model-specs.com/single_post"
        res.metadata.foobar.should eq "Baz"
        res.name.should eq "A blog post"
      end
    end
  end

end
