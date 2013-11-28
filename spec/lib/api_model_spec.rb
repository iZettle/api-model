require 'spec_helper'
require 'support/mock_models/blog_post'

describe ApiModel do

  describe "retrieving a single object" do
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

end