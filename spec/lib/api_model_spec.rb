require 'spec_helper'
require 'support/mock_models/blog_post'

describe ApiModel do

  describe "sending different types of requests" do
    before do
      BlogPost.configure_api_model do |config|
        config.api_host = "http://api-model-specs.com"
      end
    end

    it "should be possible to send a GET request" do
      get_request = VCR.use_cassette('posts') { BlogPost.get_json "/single_post" }
      get_request.http_response.request_method.should eq :get
    end

    it "should be possible to send a POST request" do
      post_request = VCR.use_cassette('posts') { BlogPost.post_json "/posts" }
      post_request.http_response.request_method.should eq :post
    end
  end

  describe "retrieving a single object" do
    describe "with the default builder" do
      let(:blog_post) do
        VCR.use_cassette('posts') do
          BlogPost.get_json "http://api-model-specs.com/single_post"
        end
      end

      it "should run the request and objectify the response hash" do
        blog_post.should be_a(BlogPost)
        blog_post.name.should eq "foo"
      end
    end

    describe "with a custom builder" do
      let(:custom_built_blog_post) do
        VCR.use_cassette('posts') do
          BlogPost.get_json "http://api-model-specs.com/single_post", builder: BlogPost::CustomBuilder.new
        end
      end

      it "should be possible to use a custom builder class when objectifing" do
        custom_built_blog_post.should be_a(BlogPost)
        custom_built_blog_post.title.should eq "FOOBAR"
      end
    end
  end

end