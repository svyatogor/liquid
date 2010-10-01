require 'spec_helper'

describe "Liquid Rendering" do
  describe "If/Else/Unless" do

    describe "{% if %}" do
      it "should show/hide content correctly when passed a boolean constant" do
        render(' {% if false %} this text should not go into the output {% endif %} ').should == "  "
        render(' {% if true %} this text should not go into the output {% endif %} ').should == "  this text should not go into the output  "
        render('{% if false %} you suck {% endif %} {% if true %} you rock {% endif %}?  ').should == "  you rock ?  "
      end

      it "should show/hide content correctly when passed a variable" do
        template = Liquid::Template.parse(' {% if var %} YES {% endif %} ')
        template.render('var' => true).should == "  YES  "
        template.render('var' => false).should == "  "

        render('{% if var %} NO {% endif %}', 'var' => false).should == ''
        render('{% if var %} NO {% endif %}', 'var' => nil).should == ''
        render('{% if foo.bar %} NO {% endif %}', 'foo' => {'bar' => false}).should == ''
        render('{% if foo.bar %} NO {% endif %}', 'foo' => {}).should == ''
        render('{% if foo.bar %} NO {% endif %}', 'foo' => nil).should == ''
        render('{% if foo.bar %} NO {% endif %}', 'foo' => true).should == ''

        render('{% if var %} YES {% endif %}', 'var' => "text").should == ' YES '
        render('{% if var %} YES {% endif %}', 'var' => true).should == ' YES '
        render('{% if var %} YES {% endif %}', 'var' => 1).should == ' YES '
        render('{% if var %} YES {% endif %}', 'var' => {}).should == ' YES '
        render('{% if var %} YES {% endif %}', 'var' => []).should == ' YES '
        render('{% if "foo" %} YES {% endif %}').should == ' YES '
        render('{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => true}).should == ' YES '
        render('{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => "text"}).should == ' YES '
        render('{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => 1 }).should == ' YES '
        render('{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => {} }).should == ' YES '
        render('{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => [] }).should == ' YES '

        render('{% if var %} NO {% else %} YES {% endif %}', 'var' => false).should == ' YES '
        render('{% if var %} NO {% else %} YES {% endif %}', 'var' => nil).should == ' YES '
        render('{% if var %} YES {% else %} NO {% endif %}', 'var' => true).should == ' YES '
        render('{% if "foo" %} YES {% else %} NO {% endif %}', 'var' => "text").should == ' YES '

        render('{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo' => {'bar' => false}).should == ' YES '
        render('{% if foo.bar %} YES {% else %} NO {% endif %}', 'foo' => {'bar' => true}).should == ' YES '
        render('{% if foo.bar %} YES {% else %} NO {% endif %}', 'foo' => {'bar' => "text"}).should == ' YES '
        render('{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo' => {'notbar' => true}).should == ' YES '
        render('{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo' => {}).should == ' YES '
        render('{% if foo.bar %} NO {% else %} YES {% endif %}', 'notfoo' => {'bar' => true}).should == ' YES '
      end

      it "should allow nested if conditionals" do
        render('{% if false %}{% if false %} NO {% endif %}{% endif %}').should == ''
        render('{% if false %}{% if true %} NO {% endif %}{% endif %}').should == ''
        render('{% if true %}{% if false %} NO {% endif %}{% endif %}').should == ''
        render('{% if true %}{% if true %} YES {% endif %}{% endif %}').should == ' YES '

        render('{% if true %}{% if true %} YES {% else %} NO {% endif %}{% else %} NO {% endif %}').should == ' YES '
        render('{% if true %}{% if false %} NO {% else %} YES {% endif %}{% else %} NO {% endif %}').should == ' YES '
        render('{% if false %}{% if true %} NO {% else %} NONO {% endif %}{% else %} YES {% endif %}').should == ' YES '
      end

      it "should allow if comparisons against null" do
        render('{% if null < 10 %} NO {% endif %}').should == ''
        render('{% if null <= 10 %} NO {% endif %}').should == ''
        render('{% if null >= 10 %} NO {% endif %}').should == ''
        render('{% if null > 10 %} NO {% endif %}').should == ''
        render('{% if 10 < null %} NO {% endif %}').should == ''
        render('{% if 10 <= null %} NO {% endif %}').should == ''
        render('{% if 10 >= null %} NO {% endif %}').should == ''
        render('{% if 10 > null %} NO {% endif %}').should == ''
      end

      it "should raise a syntax error if there's no closing endif" do
        expect {
          render('{% if jerry == 1 %}')
        }.to raise_error(Liquid::SyntaxError)
      end

      it "should raise a syntax error if there's variable argument" do
        expect {
          render('{% if %}')
        }.to raise_error(Liquid::SyntaxError)
      end

      it "should work with custom conditions" do
        Liquid::Condition.operators['containz'] = :[]

        render("{% if 'bob' containz 'o' %}yes{% endif %}").should == "yes"
        render("{% if 'bob' containz 'f' %}yes{% else %}no{% endif %}").should == "no"

      end

      context "or conditionals" do
        it "should work correctly when passed 2 variables" do
          body = '{% if a or b %} YES {% endif %}'

          render(body, 'a' => true, 'b' => true).should == " YES "
          render(body, 'a' => true, 'b' => false).should == " YES "
          render(body, 'a' => false, 'b' => true).should == " YES "
          render(body, 'a' => false, 'b' => false).should == ""
        end

        it "should work correctly when passed 3 variables" do
          body = '{% if a or b or c %} YES {% endif %}'

          render(body, 'a' => false, 'b' => false, 'c' => true).should == " YES "
          render(body, 'a' => false, 'b' => false, 'c' => false).should == ""
        end

        it "should work correctly when passed comparison operators" do
          data = {'a' => true, 'b' => true}

          render('{% if a == true or b == true %} YES {% endif %}', data).should == " YES "
          render('{% if a == true or b == false %} YES {% endif %}', data).should == " YES "
          render('{% if a == false or b == true %} YES {% endif %}', data).should == " YES "
          render('{% if a == false or b == false %} YES {% endif %}', data).should == ""
        end

        it "should handle correctly when used with string comparisons" do
          awful_markup = "a == 'and' and b == 'or' and c == 'foo and bar' and d == 'bar or baz' and e == 'foo' and foo and bar"
          data = {'a' => 'and', 'b' => 'or', 'c' => 'foo and bar', 'd' => 'bar or baz', 'e' => 'foo', 'foo' => true, 'bar' => true}

          render("{% if #{awful_markup} %} YES {% endif %}", data).should == " YES "
        end

        it "should handle correctly when using nested expression comparisons" do
          data = {'order' => {'items_count' => 0}, 'android' => {'name' => 'Roy'}}

          render("{% if android.name == 'Roy' %} YES {% endif %}", data).should == " YES "
          render("{% if order.items_count == 0 %} YES {% endif %}", data).should == " YES "
        end
      end

      context "and conditionals" do
        it "should work correctly when passed 2 variables" do
          body = '{% if a and b %} YES {% endif %}'

          render(body, 'a' => true, 'b' => true).should == " YES "
          render(body, 'a' => true, 'b' => false).should == ""
          render(body, 'a' => false, 'b' => true).should == ""
          render(body, 'a' => false, 'b' => false).should == ""
        end
      end
    end

    describe "{% if %} {% else %}" do
      it "should render the right block based on the input" do
        render('{% if false %} NO {% else %} YES {% endif %}').should == " YES "
        render('{% if true %} YES {% else %} NO {% endif %}').should == " YES "
        render('{% if "foo" %} YES {% else %} NO {% endif %}').should == " YES "
      end

      it "should allow elsif helper" do
        render('{% if 0 == 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}').should == '0'
        render('{% if 0 != 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}').should == '1'
        render('{% if 0 != 0 %}0{% elsif 1 != 1%}1{% else %}2{% endif %}').should == '2'
        render('{% if false %}if{% elsif true %}elsif{% endif %}').should == 'elsif'
      end
    end

    describe "{% unless %}" do
      it "should show/hide content correctly when passed a boolean constant" do
        render(' {% unless true %} this text should not go into the output {% endunless %} ').should ==
               '  '

        render(' {% unless false %} this text should go into the output {% endunless %} ').should ==
               '  this text should go into the output  '

        render('{% unless true %} you suck {% endunless %} {% unless false %} you rock {% endunless %}?').should ==
               '  you rock ?'

      end

      it "should work within a loop" do
        data = {'choices' => [1, nil, false]}
        render('{% for i in choices %}{% unless i %}{{ forloop.index }}{% endunless %}{% endfor %}', data).should == '23'
      end

    end

    describe "{% unless %} {% else %}" do
      it "should show/hide the section based on the passed in data" do
        render('{% unless true %} NO {% else %} YES {% endunless %}').should == ' YES '
        render('{% unless false %} YES {% else %} NO {% endunless %}').should == ' YES '
        render('{% unless "foo" %} NO {% else %} YES {% endunless %}').should == ' YES '
      end

      it "should work within a loop" do
        data = {'choices' => [1, nil, false]}
        render('{% for i in choices %}{% unless i %} {{ forloop.index }} {% else %} TRUE {% endunless %}{% endfor %}', data).should ==
               ' TRUE  2  3 '
      end
    end

  end

end