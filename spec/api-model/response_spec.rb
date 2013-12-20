require 'spec_helper'
require 'support/mock_models/blog_post'
require 'support/mock_models/user'

describe ApiModel::Response do

  let(:valid_response) do
    VCR.use_cassette('posts') do
      ApiModel::HttpRequest.new(path: "http://api-model-specs.com/single_post", method: :get, builder: BlogPost).run
    end
  end

  describe "parsing the json body" do

  end

  describe "using a custom json root on the response body" do
    let :users do
      User.api_config do |c|
        c.json_root = "users"
      end
      VCR.use_cassette('users') { User.get_json "http://api-model-specs.com/users" }
    end

    it 'should use the json root to build from' do
      users.should be_a Array
      users.size.should eq 3

      users.each do |user|
        user.should be_a User
      end
    end
  end

  describe "using a multi-level json root on the response body" do
    let :user_search do
      VCR.use_cassette('users') { User.get_json "http://api-model-specs.com/search" }
    end

    it 'should use the deep json root to build from' do
      User.api_config { |c| c.json_root = "search.results.users" }

      user_search.should be_a Array
      user_search.size.should eq 3

      user_search.each do |user|
        user.should be_a User
      end
    end

    it 'should raise a ApiModel::ResponseBuilderError exception if the hash does not contain the key' do
      User.api_config { |c| c.json_root = "search.results.users.foo" }

      expect {
        user_search
      }.to raise_error(ApiModel::ResponseBuilderError)
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
    let(:single_object) do
      valid_response.stub(:response_body).and_return name: "foo"
      valid_response.build_objects
    end

    let(:array_of_objects) do
      valid_response.stub(:response_body).and_return [{name: "foo"}, {name: "bar"}]
      valid_response.build_objects
    end

    let(:empty_response) do
      valid_response.stub(:response_body).and_return nil
      valid_response.build_objects
    end

    it "should build a single object" do
      single_object.should be_a(BlogPost)
      single_object.name.should eq "foo"
    end

    it "should build an array of objects" do
      array_of_objects[0].should be_a(BlogPost)
      array_of_objects[0].name.should eq "foo"

      array_of_objects[1].should be_a(BlogPost)
      array_of_objects[1].name.should eq "bar"
    end

    it "should include the ApiModel::HttpRequest object" do
      single_object.http_response.should be_a(ApiModel::HttpRequest)
    end

    it "should include the #response_body" do
      single_object.response_body.should eq name: "foo"
    end

    it 'should return nil if the api returns an empty body' do
      empty_response.should be_nil
    end
  end

  describe "passing core methods down to the built class" do
    ApiModel::Response::FALL_THROUGH_METHODS.each do |fall_trhough_method|
      it "should pass ##{fall_trhough_method} on the built object class" do
        allow_message_expectations_on_nil
        valid_response.objects.should_receive(fall_trhough_method)
        valid_response.send fall_trhough_method
      end
    end
  end

  describe "raising exceptions" do
    describe "for requests which return a 401" do
      let :api_request do
        VCR.use_cassette('errors') do
          BlogPost.get_json "http://api-model-specs.com/needs_auth"
        end
      end

      it 'should raise an ApiModel::UnauthenticatedError if raise_on_unauthenticated is true' do
        BlogPost.api_config { |c| c.raise_on_unauthenticated = true }
        expect {
          api_request
        }.to raise_error(ApiModel::UnauthenticatedError)
      end

      it 'should not raise an ApiModel::UnauthenticatedError if raise_on_unauthenticated is false' do
        BlogPost.api_config { |c| c.raise_on_unauthenticated = false }
        expect {
          api_request
        }.to_not raise_error
      end
    end

    describe "for requests which return a 404" do
      let :api_request do
        VCR.use_cassette('errors') do
          BlogPost.get_json "http://api-model-specs.com/not_found"
        end
      end

      it 'should raise an ApiModel::NotFoundError if raise_on_not_found is true' do
        BlogPost.api_config { |c| c.raise_on_not_found = true }
        expect {
          api_request
        }.to raise_error(ApiModel::NotFoundError)
      end

      it 'should not raise an ApiModel::NotFoundError if raise_on_not_found is false' do
        BlogPost.api_config { |c| c.raise_on_not_found = false }
        expect {
          api_request
        }.to_not raise_error
      end
    end
  end

end