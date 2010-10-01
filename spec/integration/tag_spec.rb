require 'spec_helper'

describe "Liquid Rendering" do
  describe "Tags" do

    describe "{% assign %}" do

      it "should assign a variable to a string" do
        render('{%assign var = "yo" %} var:{{var}} ').should == " var:yo "
        render("{%assign var = 'yo' %} var:{{var}} ").should == " var:yo "
        render("{%assign var='yo' %} var:{{var}} ").should == " var:yo "
        render("{%assign var='yo'%} var:{{var}} ").should == " var:yo "

        render('{%assign var="" %} var:{{var}} ').should == " var: "
        render("{%assign var='' %} var:{{var}} ").should == " var: "
      end

      it "should assign a variable to an integer" do
        render('{%assign var = 1 %} var:{{var}} ').should == " var:1 "
        render("{%assign var=1 %} var:{{var}} ").should == " var:1 "
        render("{%assign var =1 %} var:{{var}} ").should == " var:1 "
      end

      it "should assign a variable to a float" do
        render('{%assign var = 1.011 %} var:{{var}} ').should == " var:1.011 "
        render("{%assign var=1.011 %} var:{{var}} ").should == " var:1.011 "
        render("{%assign var =1.011 %} var:{{var}} ").should == " var:1.011 "
      end

      it "should assign a variable that includes a hyphen" do
        render('{%assign a-b = "yo" %} {{a-b}} ').should == " yo "
        render('{{a-b}}{%assign a-b = "yo" %} {{a-b}} ').should == " yo "
        render('{%assign a-b = "yo" %} {{a-b}} {{a}} {{b}} ', 'a' => 1, 'b' => 2).should == " yo 1 2 "
      end

      it "should assign a variable to a complex accessor" do
        data = {'var' => {'a:b c' => {'paged' => '1' }}}
        render('{%assign var2 = var["a:b c"].paged %}var2: {{var2}}', data).should == 'var2: 1'
      end

      it "should assign var2 to 'hello' when var is 'hello'" do
        data = {'var' => 'Hello' }
        render('var2:{{var2}} {%assign var2 = var%} var2:{{var2}}',data).should == 'var2:  var2:Hello'
      end

      it "should assign the variable in a global context, even if it is in a block" do
        render( '{%for i in (1..2) %}{% assign a = "variable"%}{% endfor %}{{a}}'  ).should == "variable"
      end
    end

    context "{% capture %}" do
      it "should capture the result of a block into a variable" do
        data = {'var' => 'content' }
        render('{{ var2 }}{% capture var2 %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}', data).should == 'content foo content foo '
      end

      it "should throw an error when it detects bad syntax" do
        data = {'var' => 'content'}
        expect {
          render('{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}', data)
        }.to raise_error(Liquid::SyntaxError)
      end
    end

    context "{% cycle %}" do

      it "should cycle through a list of strings" do
        render('{%cycle "one", "two"%}').should == 'one'
        render('{%cycle "one", "two"%} {%cycle "one", "two"%}').should == 'one two'
        render('{%cycle "", "two"%} {%cycle "", "two"%}').should == ' two'
        render('{%cycle "one", "two"%} {%cycle "one", "two"%} {%cycle "one", "two"%}').should == 'one two one'
        render('{%cycle "text-align: left", "text-align: right" %} {%cycle "text-align: left", "text-align: right"%}').should == 'text-align: left text-align: right'
      end

      it "should keep track of multiple cycles" do
        render('{%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%}').should == '1 2 1 1 2 3 1'
      end

      it "should keep track of multiple named cycles" do
        render('{%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %}').should == 'one one two two one one'
      end

      it "should allow multiple named cycles with names from context" do
        data = {"var1" => 1, "var2" => 2 }
        render('{%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %}', data).should == 'one one two two one one'
      end
    end


  end
end