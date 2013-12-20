require 'spec_helper'
require 'support/mock_models/banana'
require 'support/mock_models/multiple_hosts'
require 'support/mock_models/blog_post'

describe ApiModel, "Configuration" do

  after(:each) do
    Banana.reset_api_configuration
    BlogPost.reset_api_configuration
  end

  describe "api_host" do
    it "should set the api host for all classes which inherit ApiModel::Base" do
      ApiModel::Base.api_config do |config|
        config.host = "foobarbaz.com"
      end

      Banana.api_model_configuration.host.should eq "foobarbaz.com"
    end

    it "should not override different classes configurations" do
      MultipleHostsFoo.api_model_configuration.host.should eq("http://foo.com")
      MultipleHostsBar.api_model_configuration.host.should eq("http://bar.com")
      MultipleHostsNone.api_model_configuration.host.should be_nil
    end
  end

  describe "json_root" do
    it 'should be possible to set on a class' do
      Banana.api_config do |config|
        config.json_root = "foo_bar"
      end

      Banana.api_model_configuration.json_root.should eq "foo_bar"
    end
  end

  describe "headers" do
    it 'should create default headers for content type and accepts' do
      headers = Banana.api_model_configuration.headers
      headers["Content-Type"].should eq "application/json; charset=utf-8"
      headers["Accept"].should eq "application/json"
    end

    it 'should be possible to set new headers' do
      ApiModel::Base.api_config { |config| config.headers = { foo: "bar" } }
      Banana.api_model_configuration.headers[:foo].should eq "bar"
    end

    it 'should retain the default headers when you add a new one' do
      ApiModel::Base.api_config { |config| config.headers = { foo: "bar" } }

      headers = Banana.api_model_configuration.headers
      headers.should have_key "Accept"
      headers.should have_key "Content-Type"
    end

    it 'should be possible to override default headers' do
      ApiModel::Base.api_config { |config| config.headers = { "Accept" => "image/gif" } }
      Banana.api_model_configuration.headers["Accept"].should eq "image/gif"
    end
  end

  describe "cache_strategy" do
    it 'should default to NoCache' do
      ApiModel::Base.api_model_configuration.cache_strategy.should eq ApiModel::CacheStrategies::NoCache
    end
  end

  describe "parser" do
    it 'should default to the internal Json parser' do
      ApiModel::Base.api_model_configuration.parser.should be_an_instance_of ApiModel::ResponseParser::Json
    end

    it 'should be used when handling api responses' do
      ApiModel::ResponseParser::Json.any_instance.should_receive(:parse).with("{\"name\":\"foo\"}")
      VCR.use_cassette('posts') { BlogPost.get_json "http://api-model-specs.com/single_post"}
    end

    class CustomParser
      def parse(body)
        { name: "Hello world" }
      end
    end

    it 'should be possible to set a custom parser' do
      BlogPost.api_config { |config| config.parser = CustomParser.new }
      CustomParser.any_instance.should_receive(:parse).with("{\"name\":\"foo\"}")
      VCR.use_cassette('posts') { BlogPost.get_json "http://api-model-specs.com/single_post"}
    end
  end

  describe "builder" do
    it 'should defult to nil' do
      ApiModel::Base.api_model_configuration.builder.should be_nil
    end

    class CustomBuilder
      def build(response)
      end
    end

    it 'should be possible to set a custom builder' do
      BlogPost.api_config { |config| config.builder = CustomBuilder.new }
      CustomBuilder.any_instance.should_receive(:build).with({ "name" => "foo"})
      VCR.use_cassette('posts') { BlogPost.get_json "http://api-model-specs.com/single_post"}
    end
  end

  it 'should not unset other config values when you set a new one' do
    ApiModel::Base.api_config { |c| c.host = "foo.com" }
    Banana.api_config { |c| c.json_root = "banana" }

    Banana.api_model_configuration.host.should eq "foo.com"
    Banana.api_model_configuration.json_root.should eq "banana"
  end

  it 'should override config values from the superclass if it is changed' do
    ApiModel::Base.api_config { |c| c.host = "will-go.com" }
    Banana.api_config { |c| c.host = "new-host.com" }

    Banana.api_model_configuration.host.should eq "new-host.com"
  end

end