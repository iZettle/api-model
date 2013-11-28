require 'spec_helper'
require 'support/mock_models/banana'

describe ApiModel, "initialization" do

  let(:banana) { Banana.new color: "yellow", size: "large" }

  it "should set attributes when initializing with a hash" do
    expect(banana.color).to eq "yellow"
    expect(banana.size).to eq "large"
  end

  it "should be easy to update attributes once set" do
    banana.update_attributes color: "green", size: "small"
    expect(banana.color).to eq "green"
    expect(banana.size).to eq "small"
  end

  it "should run callbacks on initialize" do
    banana.ripe.should eq true
  end

  it "should not be persisted by default" do
    banana.persisted?.should eq false
  end

end