describe "Liquid Rendering" do
  describe "comments" do
    context "{% comment %}" do
      it "should not render comment blocks" do
        render('{%comment%}{%endcomment%}').should == ''
        render('{%comment%}{% endcomment %}').should == ''
        render('{% comment %}{%endcomment%}').should == ''
        render('{% comment %}{% endcomment %}').should == ''
        render('{%comment%}comment{%endcomment%}').should == ''
        render('{% comment %}comment{% endcomment %}').should == ''
      end

      it "should render the other content that isnt inside the comment block" do

        render(%|the comment block should be removed {%comment%} be gone.. {%endcomment%} .. right?|).should ==
               %|the comment block should be removed  .. right?|

        render('foo{%comment%}comment{%endcomment%}bar').should == 'foobar'
        render('foo{% comment %}comment{% endcomment %}bar').should == 'foobar'
        render('foo{%comment%} comment {%endcomment%}bar').should == 'foobar'
        render('foo{% comment %} comment {% endcomment %}bar').should == 'foobar'

        render('foo {%comment%} {%endcomment%} bar').should == 'foo  bar'
        render('foo {%comment%}comment{%endcomment%} bar').should == 'foo  bar'
        render('foo {%comment%} comment {%endcomment%} bar').should == 'foo  bar'

        render('foo{%comment%}
                                         {%endcomment%}bar').should == "foobar"
      end
    end
  end
end