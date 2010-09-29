require 'spec_helper'

describe "Liquid Rendering" do
  describe "Template Inheritance" do

    class TestFileSystem
      def read_template_file(template_path)
        case template_path
        when "parent-template"
          "Hurrah!"
        when "parent-with-variable"
          "Hello, {{ name }}!"
        when "parent-with-parent"
          "{% extends parent-with-variable %}"
        else
          raise "TestFileSystem Error: No template defined for #{template_path}"
        end
      end
    end

    before(:each) do
      Liquid::Template.file_system = TestFileSystem.new
    end

    it "should allow extending a path" do
      template = Liquid::Template.parse "{% extends parent-template %}"
      template.render.should == "Hurrah!"
    end

    # TODO
    # it "should allow extending, with additional content" do
    #   template = Liquid::Template.parse "{% extends parent-template %} Huzzah!"
    #   template.render.should == "Hurrah! Huzzah!"
    # end

    it "should allow access to the context from the inherited template" do
      template = Liquid::Template.parse "{% extends parent-with-variable %}"
      template.render('name' => 'Joe').should == "Hello, Joe!"
    end

    it "show allow deep nesting of inherited templates" do
      template = Liquid::Template.parse "{% extends parent-with-parent %}"
      template.render('name' => 'Joe').should == "Hello, Joe!"
    end


  end
end