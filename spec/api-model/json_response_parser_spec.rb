require 'spec_helper'

describe ApiModel::ResponseParser::Json do

  it "should produce a hash given valid json" do
    ApiModel::ResponseParser::Json.new.parse("{\"name\":\"foo\"}")["name"].should eq "foo"
  end

  it "should catch errors from parsing invalid json" do
    ApiModel::Log.should_receive(:info).with "Could not parse JSON response: blah"

    expect {
      ApiModel::ResponseParser::Json.new.parse("blah")
    }.to_not raise_error
  end

end
