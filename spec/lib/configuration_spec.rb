require 'spec_helper'
require 'support/mock_models/banana'
require 'support/mock_models/multiple_hosts'

describe ApiModel, "Configuration" do

  describe "api_host" do
    before do
      Banana.configure_api_model do |config|
        config.host = "foobarbaz.com"
      end
    end

    it "should set the api host for all classes which inherit ApiModel::Base" do
      Banana.api_model_configuration.host.should eq "foobarbaz.com"
    end

    describe "with combinations of setting different hosts" do
      it "should no override each other" do
        MultipleHostsFoo.api_model_configuration.host.should eq("http://foo.com")
        MultipleHostsBar.api_model_configuration.host.should eq("http://bar.com")
        MultipleHostsNone.api_model_configuration.host.should eq("")
      end
    end
  end

end