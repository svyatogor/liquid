require 'spec_helper'

describe "Liquid Rendering" do
  describe "Template Inheritance" do
    before(:each) do
      @templates ||= {}
    end

    before(:each) do
      Liquid::Template.file_system = self
    end

    def read_template_file(template_path)
      @template_path ||= {}
      @templates[template_path] || raise("TestFileSystem Error: No template defined for #{template_path}")
    end

    it "should allow extending a path" do
      @templates['parent-template'] = "Hurrah!"

      template = Liquid::Template.parse "{% extends parent-template %}"
      template.render.should == "Hurrah!"
    end

    # TODO
    # it "should allow extending, with additional content" do
    #   template = Liquid::Template.parse "{% extends parent-template %} Huzzah!"
    #   template.render.should == "Hurrah! Huzzah!"
    # end

    it "should allow access to the context from the inherited template" do
      @templates['parent-with-variable'] = "Hello, {{ name }}!"

      template = Liquid::Template.parse "{% extends parent-with-variable %}"
      template.render('name' => 'Joe').should == "Hello, Joe!"
    end

    it "should allow deep nesting of inherited templates" do
      @templates['parent-with-variable'] = "Hello, {{ name }}!!"
      @templates['parent-with-parent'] = "{% extends parent-with-variable %}"

      template = Liquid::Template.parse "{% extends parent-with-parent %}"
      template.render('name' => 'Joe').should == "Hello, Joe!!"
    end

    context "inherited blocks" do
      before(:each) do
        @templates['base'] = "Output / {% block content %}Hello, World!{% endblock %}"
      end

      it "should allow overriding blocks from an inherited template" do
        output = render("{% extends base %}{% block content %}Hola, Mundo!{% endblock %}")
        output.should == 'Output / Hola, Mundo!'
      end

      it "should allow an overriding block to call super" do
        output = render("{% extends base %}{% block content %}Lorem ipsum: {{block.super}}{% endblock %}")
        output.should == 'Output / Lorem ipsum: Hello, World!'
      end

      it "should allow deep nested includes to call super within overriden blocks" do
        @templates['deep'] = "{% extends base %}{% block content %}Deep: {{block.super}}{% endblock %}"
        output = render("{% extends deep %}{% block content %}Lorem ipsum: {{block.super}}{% endblock %}")
        output.should == 'Output / Lorem ipsum: Deep: Hello, World!'

        @templates['nested_and_deep'] = "{% extends base %}{% block content %}Deep: {{block.super}} -{% block inner %}FOO{% endblock %}-{% endblock %}"
        output = render("{% extends nested_and_deep %}{% block inner %}BAR{% endblock %}")
        output.should == 'Output / Deep: Hello, World! -BAR-'
      end
    end
  end
end