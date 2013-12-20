require 'spec_helper'
require 'support/mock_models/blog_post'

describe ApiModel::HttpRequest do

  describe "default attributes" do
    subject { ApiModel::HttpRequest.new }

    it "should default #method to :get" do
      subject.method.should eq :get
    end

    it "should default #options to a hash with headers" do
      subject.options.should be_a Hash
      subject.options[:headers].should_not be_nil
    end
  end

  describe "callbacks" do
    class ApiModel::HttpRequest
      before_run :do_something_before_run
      def do_something_before_run; end
    end

    it 'should be possible to set callbacks on the run method' do
      ApiModel::HttpRequest.any_instance.should_receive(:do_something_before_run).once
      VCR.use_cassette('posts') { BlogPost.get_json "http://api-model-specs.com/single_post"}
    end
  end

  describe "using api_host" do
    let(:blog_post) do
      BlogPost.api_config do |config|
        config.host = "http://api-model-specs.com"
      end

      VCR.use_cassette('posts') do
        BlogPost.get_json "/single_post"
      end
    end

    it "should be used with #path to generate a #full_path" do
      blog_post.http_response.api_call.request.url.should eq "http://api-model-specs.com/single_post"
    end
  end

  describe "headers" do
    let :request_headers do
      BlogPost.api_config { |config| config.host = "http://api-model-specs.com" }
      blog_post = VCR.use_cassette('posts') { BlogPost.get_json "/single_post" }
      blog_post.http_response.api_call.request.options[:headers]
    end

    it 'should use the default content type header' do
      request_headers["Content-Type"].should eq ApiModel::Configuration.new.headers["Content-Type"]
    end

    it 'should use the default accept header' do
      request_headers["Accept"].should eq ApiModel::Configuration.new.headers["Accept"]
    end
  end

  describe "sending a GET request" do
    let(:request) { ApiModel::HttpRequest.new path: "http://api-model-specs.com/posts", method: :get }

    it "should use typhoeus to send a request" do
      VCR.use_cassette('posts') do
        request.run
      end

      request.api_call.success?.should eq true
    end
  end

  describe "cache_id" do
    it 'should use options and the request path to create an identifier for the cache' do
      a = ApiModel::HttpRequest.new options: {params: { foo: "bar" } }, path: "/box"
      a.cache_id.should eq "/boxfoobar"
    end

    it 'should be overridable' do
      a = ApiModel::HttpRequest.new options: { params: { foo: "bar" } }, path: "/box", cache_id: "hello"
      a.cache_id.should eq "hello"
    end
  end
end