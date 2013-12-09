require 'spec_helper'
require 'support/mock_models/banana'
require 'support/mock_models/multiple_hosts'

describe ApiModel, "Configuration" do

  after(:each) do
    Banana.reset_api_configuration
  end

  describe "api_host" do
    it "should set the api host for all classes which inherit ApiModel::Base" do
      ApiModel::Base.api_model do |config|
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
      Banana.api_model do |config|
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
      ApiModel::Base.api_model { |config| config.headers = { foo: "bar" } }
      Banana.api_model_configuration.headers[:foo].should eq "bar"
    end

    it 'should retain the default headers when you add a new one' do
      ApiModel::Base.api_model { |config| config.headers = { foo: "bar" } }

      headers = Banana.api_model_configuration.headers
      headers.should have_key "Accept"
      headers.should have_key "Content-Type"
    end

    it 'should be possible to override default headers' do
      ApiModel::Base.api_model { |config| config.headers = { "Accept" => "image/gif" } }
      Banana.api_model_configuration.headers["Accept"].should eq "image/gif"
    end
  end

  it 'should not unset other config values when you set a new one' do
    ApiModel::Base.api_model { |c| c.host = "foo.com" }
    Banana.api_model { |c| c.json_root = "banana" }

    Banana.api_model_configuration.host.should eq "foo.com"
    Banana.api_model_configuration.json_root.should eq "banana"
  end

  it 'should override config values from the superclass if it is changed' do
    ApiModel::Base.api_model { |c| c.host = "will-go.com" }
    Banana.api_model { |c| c.host = "new-host.com" }

    Banana.api_model_configuration.host.should eq "new-host.com"
  end

end