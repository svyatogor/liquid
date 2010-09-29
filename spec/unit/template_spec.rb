require 'spec_helper'

module Liquid
  describe Template do

    def tokenize(text)
      Template.new.send(:tokenize, text)
    end

    it "should tokenize strings" do
      tokenize(' ').should == [' ']
      tokenize('hello world').should == ['hello world']
    end

    it "should tokenize variables" do
      tokenize('{{funk}}').should == ['{{funk}}']
      tokenize(' {{funk}} ').should == [' ', '{{funk}}', ' ']
      tokenize(' {{funk}} {{so}} {{brother}} ').should == [' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' ']
      tokenize(' {{  funk  }} ').should == [' ', '{{  funk  }}', ' ']
    end

    it "should tokenize blocks" do
      tokenize('{%comment%}').should == ['{%comment%}']
      tokenize(' {%comment%} ').should == [' ', '{%comment%}', ' ']
      tokenize(' {%comment%} {%endcomment%} ').should == [' ', '{%comment%}', ' ', '{%endcomment%}', ' ']
      tokenize("  {% comment %} {% endcomment %} ").should == ['  ', '{% comment %}', ' ', '{% endcomment %}', ' ']
    end

    it "should persist instance assignment on the same template object between parses " do
      t = Template.new
      t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render.should == 'from instance assigns'
      t.parse("{{ foo }}").render.should == 'from instance assigns'
    end

    it "should persist instance assingment on the same template object between renders" do
      t = Template.new.parse("{{ foo }}{% assign foo = 'foo' %}{{ foo }}")
      t.render.should == "foo"
      t.render.should == "foofoo"
    end

    it "should not persist custom assignments on the same template" do
      t = Template.new
      t.parse("{{ foo }}").render('foo' => 'from custom assigns').should == 'from custom assigns'
      t.parse("{{ foo }}").render.should == ''
    end

    it "should squash instance assignments with custom assignments when specified" do
      t = Template.new
      t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render.should == 'from instance assigns'
      t.parse("{{ foo }}").render('foo' => 'from custom assigns').should == 'from custom assigns'
    end

    it "should squash instance assignments with persistent assignments" do
      t = Template.new
      t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render.should == 'from instance assigns'
      t.assigns['foo'] = 'from persistent assigns'
      t.parse("{{ foo }}").render.should == 'from persistent assigns'
    end

    it "should call lambda only once from persistent assigns over multiple parses and renders" do
      t = Template.new
      t.assigns['number'] = lambda { @global ||= 0; @global += 1 }
      t.parse("{{number}}").render.should == '1'
      t.parse("{{number}}").render.should == '1'
      t.render.should == '1'
      @global = nil
    end

    it "should call lambda only once from custom assigns over multiple parses and renders" do
      t = Template.new
      assigns = {'number' => lambda { @global ||= 0; @global += 1 }}
      t.parse("{{number}}").render(assigns).should == '1'
      t.parse("{{number}}").render(assigns).should == '1'
      t.render(assigns).should == '1'
      @global = nil
    end
  end
end