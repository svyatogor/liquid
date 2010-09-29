require 'spec_helper'

module Liquid
  describe "Liquid Parsing Quirks" do
    it "should work with css syntax" do
      template = parse(" div { font-weight: bold; } ")
      template.render.should == " div { font-weight: bold; } "
      template.root.nodelist[0].should be_an_instance_of(String)
    end

    it "should raise an error on a single close brace" do
      expect {
        parse("text {{method} oh nos!")
      }.to raise_error(SyntaxError)
    end

    it "should raise an error with double braces and no matcing closing double braces" do
      expect {
        parse("TEST {{")
      }.to raise_error(SyntaxError)
    end

    it "should raise an error with open tag and no matching close tag" do
      expect {
        parse("TEST {%")
      }.to raise_error(SyntaxError)
    end

    it "should allow empty filters" do
      parse("{{test |a|b|}}")
      parse("{{test}}")
      parse("{{|test|}}")
    end

    it "should allow meaningless parens" do
      data = {'b' => 'bar', 'c' => 'baz'}
      markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"

      render("{% if #{markup} %} YES {% endif %}", data).should == " YES "
    end

    it "should allow unexpected characters to silently eat logic" do
      markup = "true && false"
      render("{% if #{markup} %} YES {% endif %}").should == ' YES '

      markup = "false || true"
      render("{% if #{markup} %} YES {% endif %}").should == ''
    end
  end
end