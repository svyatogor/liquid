require 'spec_helper'

describe "Liquid Rendering" do
  describe "case" do

    context "{% case %}" do
      it "should render the first block with a matching {% when %} argument" do
        data = {'condition' => 1 }
        render('{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}', data).should == ' its 1 '

        data = {'condition' => 2 }
        render('{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}', data).should == ' its 2 '

        # dont render whitespace between case and first when
        data = {'condition' => 2 }
        render('{% case condition %} {% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}', data).should == ' its 2 '
      end

      it "should match strings correctly" do
        data = {'condition' => "string here" }
        render('{% case condition %}{% when "string here" %} hit {% endcase %}', data).should == ' hit '

        data = {'condition' => "bad string here" }
        render('{% case condition %}{% when "string here" %} hit {% endcase %}', data).should == ''
      end

      it "should not render anything if no matches found" do
        data = {'condition' => 3 }
        render(' {% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %} ', data).should == '  '
      end

      it "should evaluate variables and expressions" do
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => []).should == ''
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1]).should == '1'
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1]).should == '2'
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1]).should == ''
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1, 1]).should == ''
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1, 1, 1]).should == ''
      end

      it "should allow assignment from within a {% when %} block" do
        # Example from the shopify forums
        template = %q({% case collection.handle %}{% when 'menswear-jackets' %}{% assign ptitle = 'menswear' %}{% when 'menswear-t-shirts' %}{% assign ptitle = 'menswear' %}{% else %}{% assign ptitle = 'womenswear' %}{% endcase %}{{ ptitle }})

        render(template, "collection" => {'handle' => 'menswear-jackets'}).should == 'menswear'
        render(template, "collection" => {'handle' => 'menswear-t-shirts'}) == 'menswear'
        render(template, "collection" => {'handle' => 'x'}) == 'womenswear'
        render(template, "collection" => {'handle' => 'y'}) == 'womenswear'
        render(template, "collection" => {'handle' => 'z'}) == 'womenswear'
      end

      it "should allow the use of 'or' to chain parameters with {% when %}" do
        template = '{% case condition %}{% when 1 or 2 or 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, {'condition' => 1 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 2 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 3 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 4 }).should == ' its 4 '
        render(template, {'condition' => 5 }).should == ''

        template = '{% case condition %}{% when 1 or "string" or null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, 'condition' => 1).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'string').should == ' its 1 or 2 or 3 '
        render(template, 'condition' => nil).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'something else').should == ''
      end

      it "should allow the use of commas to chain parameters with {% when %} " do
        template = '{% case condition %}{% when 1, 2, 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, {'condition' => 1 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 2 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 3 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 4 }).should == ' its 4 '
        render(template, {'condition' => 5 }).should == ''

        template = '{% case condition %}{% when 1, "string", null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, 'condition' => 1).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'string').should == ' its 1 or 2 or 3 '
        render(template, 'condition' => nil).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'something else').should == ''
      end

      it "should raise an error when theres bad syntax" do
        expect {
          render!('{% case false %}{% when %}true{% endcase %}')
        }.to raise_error(Liquid::SyntaxError)

        expect {
          render!('{% case false %}{% huh %}true{% endcase %}')
        }.to raise_error(Liquid::SyntaxError)
      end

      context "with {% else %}" do
        it "should render the {% else %} block when no matches found" do
          data = {'condition' => 5 }
          render('{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}', data).should == ' hit '

          data = {'condition' => 6 }
          render('{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}', data).should == ' else '
        end

        it "should evaluate variables and expressions" do
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => []).should == 'else'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1]).should == '1'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1]).should == '2'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1, 1]).should == 'else'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1, 1, 1]).should == 'else'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1, 1, 1, 1]).should == 'else'


          render('{% case a.empty? %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "else"
          render('{% case false %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "false"
          render('{% case true %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "true"
          render('{% case NULL %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "else"

        end
      end
    end
  end
end