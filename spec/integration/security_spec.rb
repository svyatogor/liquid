require 'spec_helper'

describe "Liquid Rendering" do
  describe "Security" do
    module SecurityFilter
      def add_one(input)
        "#{input} + 1"
      end
    end

    it "should not allow instance eval" do
      render(" {{ '1+1' | instance_eval }} ").should == " 1+1 "
    end

    it "should not allow existing instance eval" do
      render(" {{ '1+1' | __instance_eval__ }} ").should == " 1+1 "
    end

    it "should not allow instance eval later in chain" do
      filters = {:filters => SecurityFilter}
      render(" {{ '1+1' | add_one | instance_eval }} ", {}, filters).should == " 1+1 + 1 "
    end

  end
end