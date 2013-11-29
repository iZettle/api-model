require 'spec_helper'
require 'support/mock_models/banana'
require 'support/mock_models/multiple_hosts'

describe ApiModel do
  describe "api_host" do
    it "should be possible to set the base api_host" do
      Banana.api_host = "http://api-model-specs.com"
      Banana.api_host.should eq "http://api-model-specs.com"
    end

    describe "with combinations of setting different hosts" do
      it "should no override each other" do
        MultipleHostsFoo.api_host.should eq("http://foo.com")
        MultipleHostsBar.api_host.should eq("http://bar.com")
        MultipleHostsNone.api_host.should eq("")
      end
    end
  end
end