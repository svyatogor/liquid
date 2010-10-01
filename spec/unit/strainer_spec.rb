require 'spec_helper'

module Liquid
  describe Strainer do

    let(:strainer) do
      Strainer.create(nil)
    end

    it "should remove standard Object methods" do
      strainer.respond_to?('__test__').should be_false
      strainer.respond_to?('test').should be_false
      strainer.respond_to?('instance_eval').should be_false
      strainer.respond_to?('__send__').should be_false

       # from the standard lib
       strainer.respond_to?('size').should be_true
    end

    it "should respond_to with 2 params" do
      strainer.respond_to?('size', false).should be_true
    end

    it "should repond_to_missing properly" do
      strainer.respond_to?(:respond_to_missing?).should == Object.respond_to?(:respond_to_missing?)
    end

  end
end