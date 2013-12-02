require 'spec_helper'
require 'support/mock_models/blog_post'
require 'support/mock_models/car'

describe ApiModel do

  describe "sending different types of requests" do
    before do
      BlogPost.api_model do |config|
        config.host = "http://api-model-specs.com"
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

  describe "using Hashie to build with properties" do
    describe "with a single object response" do
      let(:car) do
        VCR.use_cassette('cars') { Car.get_json "http://cars.com/one_convertable" }
      end

      it 'should build the correct object' do
        car.should be_a(Car)
      end

      it 'should correctly rename properties' do
        car.number_of_doors.should eq 2
      end

      it 'should correctly transform properties' do
        car.top_speed.should eq 600
      end

      it 'should let you define custom methods as normal' do
        car.is_fast?.should be_true
      end
    end

    describe "with a collection of objects response" do
      let(:cars) do
        VCR.use_cassette('cars') { Car.get_json "http://cars.com/fast_ones" }
      end

      it 'should build an array of the correct objects' do
        cars.should be_a(Array)
        cars.collect { |car| car.should be_a(Car) }
      end

      it 'should correctly rename properties' do
        cars.last.number_of_doors.should eq 4
      end

      it 'should correctly transform properties' do
        cars.last.top_speed.should eq 300
      end

      it 'should let you define custom methods as normal' do
        cars.last.is_fast?.should be_false
      end
    end
  end

end