require 'spec_helper'

describe "Liquid Rendering" do
  describe "Variables" do

    it "should render simple variables" do
      render('{{test}}', 'test' => 'worked').should == "worked"
      render('{{test}}', 'test' => 'worked wonderfully').should == 'worked wonderfully'
    end

    it "should render variables with whitespace" do
      render('  {{ test }}  ', 'test' => 'worked').should == '  worked  '
      render('  {{ test }}  ', 'test' => 'worked wonderfully').should == '  worked wonderfully  '
    end

    it "should ignore unknown variables" do
      render('{{ idontexistyet }}').should == ""
    end

    it "should scope hash variables" do
      data = {'test' => {'test' => 'worked'}}
      render('{{ test.test }}', data).should == "worked"
    end

    it "should render preset assigned variables" do
      template = Liquid::Template.parse("{{ test }}")
      template.assigns['test'] = 'worked'
      template.render.should == "worked"
    end

    it "should reuse parsed template" do
      template = Liquid::Template.parse("{{ greeting }} {{ name }}")
      template.assigns['greeting'] = 'Goodbye'
      template.render('greeting' => 'Hello', 'name' => 'Tobi').should == 'Hello Tobi'
      template.render('greeting' => 'Hello', 'unknown' => 'Tobi').should == 'Hello '
      template.render('greeting' => 'Hello', 'name' => 'Brian').should == 'Hello Brian'
      template.render('name' => 'Brian').should == 'Goodbye Brian'

      template.assigns.should == {'greeting' => 'Goodbye'}
    end

    it "should not get polluted with assignments from templates" do
      template = Liquid::Template.parse(%|{{ test }}{% assign test = 'bar' %}{{ test }}|)
      template.assigns['test'] = 'baz'
      template.render.should == 'bazbar'
      template.render.should == 'bazbar'
      template.render('test' => 'foo').should == 'foobar'
      template.render.should == 'bazbar'
    end

    it "should allow a hash with a default proc" do
      template = Liquid::Template.parse(%|Hello {{ test }}|)
      assigns = Hash.new { |h,k| raise "Unknown variable '#{k}'" }
      assigns['test'] = 'Tobi'

      template.render!(assigns).should == 'Hello Tobi'
      assigns.delete('test')

      expect{
        template.render!(assigns)
      }.to raise_error(RuntimeError, "Unknown variable 'test'")
    end
  end
end