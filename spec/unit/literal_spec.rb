require 'spec_helper'

module Liquid
  describe Literal do
    describe "Literal.from_shorthand" do
      it "should convert shorthand syntax to the tag" do
        Literal.from_shorthand('{{{gnomeslab}}}').should == "{% literal %}gnomeslab{% endliteral %}"
      end

      it "should ignore improper syntax" do
        text = "{% if 'hi' == 'hi' %}hi{% endif %}"
        Literal.from_shorthand(text).should == text
      end
    end
  end
end