require 'spec_helper'

describe "Liquid Rendering" do
  describe "Literals" do

    context "literal tag: {% literal %}" do
      it "should render an empty literal" do
        render('{% literal %}{% endliteral %}').should == ''
      end

      it "should render a literal with a simple value" do
        render('{% literal %}howdy{% endliteral %}').should == "howdy"
      end

      it "should ignore liquid markup" do
        inner = "{% if 'gnomeslab' contain 'liquid' %}yes{ % endif %}"
        render("{% literal %}#{inner}{% endliteral %}").should == inner
      end
    end

    context "literal shorthand: {{{}}}" do
      it "should render an empty literal" do
        render('{{{}}}').should == ''
      end

      it "should render a literal with a simple value" do
        render('{{{howdy}}}').should == "howdy"
      end

      it "should ignore liquid markup" do
        inner = "{% if 'gnomeslab' contain 'liquid' %}yes{ % endif %}"
        render("{{{#{inner}}}}").should == inner
      end
    end

  end
end