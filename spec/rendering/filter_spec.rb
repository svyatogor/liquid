require 'spec_helper'

require 'filters/money_filters'

describe "Liquid Rendering" do
  describe "Filters" do

    before(:each) do
      @context = Liquid::Context.new
    end

    def render(body)
      Liquid::Variable.new(body).render(@context)
    end

    context "with custom filters added to context" do
      before(:each) do
        @context['val'] = 1000
      end

      it "should use the local filters" do
        @context.add_filters(MoneyFilter)
        render('val | money').should == "$1000"
        render('val | money_with_underscores').should == "_$1000_"
      end

      it "should allow filters to overwrite previous ones" do
        @context.add_filters(MoneyFilter)
        @context.add_filters(CanadianMoneyFilter)
        render('val | money').should == "$1000 CAD"
      end
    end

    context "standard filters" do
      describe "size" do
        it "should return the size of a string" do
          @context['val'] = "abcd"
          render('val | size').should == 4
        end

        it "should return the size of an array" do
          @context['val'] = [1,2,3,4]
          render('val | size').should == 4
        end

        it "should return the size of a hash" do
          @context['val'] = {"one" => 1, "two" => 2, "three" => 3, "four" => 4}
          render('val | size').should == 4
        end
      end

      describe "join" do
        it "should join an array" do
          @context['val'] = [1,2,3,4]
          render('val | join').should == "1 2 3 4"
        end

        it "should join a hash" do
          @context['val'] = {"one" => 1}
          render('val | join').should == "one1"
        end

        it "should join a string" do
          @context['val'] = "one"
          render('val | join').should == "one"
        end
      end

      describe "sort" do
        it "should sort a single value" do
          @context['value'] = 3
          render("value | sort").should == [3]
        end

        it "should sort an array of numbers" do
          @context['numbers'] = [2,1,4,3]
          render("numbers | sort").should == [1,2,3,4]
        end

        it "should sort an array of words" do
          @context['words'] = ['expected', 'as', 'alphabetic']
          render("words | sort").should == ['alphabetic', 'as', 'expected']
        end

        it "should sort an array of arrays" do
          @context['arrays'] = [['flattened'], ['are']]
          render('arrays | sort').should == ['are', 'flattened']
        end
      end

      describe "strip_html" do
        it "should strip out tags around a <b>" do
          @context['user_input'] = "<b>bla blub</a>"
          render('user_input | strip_html').should == "bla blub"
        end

        it "should remove script tags entirely" do
          @context['user_input'] = "<script>alert('OMG hax!')</script>"
          render('user_input | strip_html').should == ""
        end
      end

      describe "capitalize" do
        it "should capitalize the first character" do
          @context['val'] = "blub"
          render('val | capitalize').should == 'Blub'
        end
      end
    end

    context "filters in template" do
      before(:each) do
        Liquid::Template.register_filter(MoneyFilter)
      end

      it "should use globally registered filters" do
        Liquid::Template.parse('{{1000 | money}}').render.should == "$1000"
      end

      it "should allow custom filters to override registered filters" do
        Liquid::Template.parse('{{1000 | money}}').render(nil, :filters => CanadianMoneyFilter).should == "$1000 CAD"
        Liquid::Template.parse('{{1000 | money}}').render(nil, :filters => [CanadianMoneyFilter]).should == "$1000 CAD"
      end
    end
  end
end