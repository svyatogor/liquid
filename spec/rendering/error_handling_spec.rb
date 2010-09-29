require 'spec_helper'

require 'fixtures/error_drop'

describe "Liquid Rendering" do
  describe "Error Handling" do

    context "template throws a standard error" do

      it "should render the standard error message" do
        template = Liquid::Template.parse(" {{ errors.standard_error }} ")
        template.render('errors' => ErrorDrop.new).should == " Liquid error: standard error "

        template.errors.size.should == 1
        template.errors.first.should be_an_instance_of(Liquid::StandardError)
      end
    end

    context "template throws a syntax error" do
      it "should render the syntax error message" do
        template = Liquid::Template.parse(" {{ errors.syntax_error }} ")
        template.render('errors' => ErrorDrop.new).should == " Liquid syntax error: syntax error "

        template.errors.size.should == 1
        template.errors.first.should be_an_instance_of(Liquid::SyntaxError)
      end
    end

    context "template throws an argument error" do
      it "should render the argument error message" do
        template = Liquid::Template.parse(" {{ errors.argument_error }} ")
        template.render('errors' => ErrorDrop.new).should == " Liquid error: argument error "

        template.errors.size.should == 1
        template.errors.first.should be_an_instance_of(Liquid::ArgumentError)
      end
    end

    context "template has a missing endtag" do
      it "should raise an exception when parsing" do
        expect {
          Liquid::Template.parse(" {% for a in b %} ")
        }.to raise_error(Liquid::SyntaxError)
      end
    end

    context "template has an unrecognized operator" do
      it "should render the unrecognized argument error message" do
        template = Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ')
        template.render.should == ' Liquid error: Unknown operator =! '

        template.errors.size.should == 1
        template.errors.first.should be_an_instance_of(Liquid::ArgumentError)
      end
    end


  end
end