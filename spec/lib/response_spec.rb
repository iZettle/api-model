require 'spec_helper'
require 'support/mock_models/blog_post'

describe ApiModel::Response do
  
  let(:valid_response) do
    VCR.use_cassette('posts') do
      ApiModel::HttpRequest.new(path: "http://api-model-specs.com/single_post", method: :get).run
    end
  end

  describe "parsing the json body" do
    it "should produce a hash given valid json" do
      valid_response.json_response_body.should be_a(Hash)
      valid_response.json_response_body["name"].should eq "foo"
    end

    it "should catch errors from parsing invalid json" do
      valid_response.stub_chain(:http_response, :body).and_return "blah"
      ApiModel::Log.should_receive(:info).with "Could not parse JSON response: blah"
      
      expect {
        valid_response.json_response_body
      }.to_not raise_error
    end
  end

  describe "#build" do
    it "should use the builder.build method if present" do
      builder = double
      builder.should_receive(:build).with something: "foo"

      valid_response.build builder, something: "foo"
    end

    it "should use builder.new if there's no builder.build method" do
      builder = double
      builder.should_receive(:new).with something_else: "hi"

      valid_response.build builder, something_else: "hi"
    end
  end

  describe "#build_objects" do
    it "should build a single object" do
      valid_response.stub(:json_response_body).and_return name: "foo"
      single = valid_response.build_objects BlogPost

      single.should be_a(BlogPost)
      single.name.should eq "foo"
    end

    it "should build an array of objects" do
      valid_response.stub(:json_response_body).and_return [{name: "foo"}, {name: "bar"}]
      array = valid_response.build_objects BlogPost

      array[0].should be_a(BlogPost)
      array[0].name.should eq "foo"

      array[1].should be_a(BlogPost)
      array[1].name.should eq "bar"
    end
  end

end