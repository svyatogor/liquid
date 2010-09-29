require 'spec_helper'

class OtherFileSystem
  def read_template_file(template_path)
    'from OtherFileSystem'
  end
end

describe "Liquid Rendering" do
  describe "include tag" do

    before(:each) do
      Liquid::Template.file_system = self
    end

    before(:each) do
      @templates ||= {}
      @templates['product'] = "Product: {{ product.title }} "
      @templates['locale_variables'] = "Locale: {{echo1}} {{echo2}} "
      @templates['variant'] = "Variant: {{ variant.title }} "
      @templates['nested_template'] = "{% include 'header' %} {% include 'body' %} {% include 'footer' %}"
      @templates['body'] = "body {% include 'body_detail' %}"
      @templates['nested_product_template'] = "Product: {{ nested_product_template.title }} {%include 'details'%} "
      @templates['recursively_nested_template'] = "-{% include 'recursively_nested_template' %}"
      @templates['pick_a_source'] = "from TestFileSystem"
    end

    def read_template_file(template_path)
      @template_path ||= {}
      @templates[template_path] || template_path
    end

    it "should look for file system in registers first" do
      registers = {:registers => {:file_system => OtherFileSystem.new}}
      render("{% include 'pick_a_source' %}", {}, registers).should == "from OtherFileSystem"
    end

    it "should take a with option" do
      data = {"products" => [ {'title' => 'Draft 151cm'}, {'title' => 'Element 155cm'} ]}
      render("{% include 'product' with products[0] %}", data).should == "Product: Draft 151cm "
    end

    it "should use a default name" do
      data = {"product" => {'title' => 'Draft 151cm'}}
      render("{% include 'product' %}", data).should == "Product: Draft 151cm "
    end

    it "should allow cycling through a collection with the 'for' keyword" do
      data = {"products" => [ {'title' => 'Draft 151cm'}, {'title' => 'Element 155cm'} ]}
      render("{% include 'product' for products %}")
    end

    it "should allow passing local variables" do
      # one variable
      render("{% include 'locale_variables' echo1: 'test123' %}").should == "Locale: test123  "

      # multiple variables
      data = {'echo1' => 'test123', 'more_echos' => { "echo2" => 'test321'}}
      render("{% include 'locale_variables' echo1: echo1, echo2: more_echos.echo2 %}", data).should == "Locale: test123 test321 "

    end

    it "should allow nested includes" do
      render("{% include 'body' %}").should == "body body_detail"
      render("{% include 'nested_template' %}").should == "header body body_detail footer"
    end

    it "should allow nested includes with a variable" do
      data = {"product" => {"title" => 'Draft 151cm'}}
      render("{% include 'nested_product_template' with product %}", data).should == "Product: Draft 151cm details "

      data = {"products" => [{"title" => 'Draft 151cm'}, {"title" => 'Element 155cm'}]}
      render("{% include 'nested_product_template' for products %}", data).should == "Product: Draft 151cm details Product: Element 155cm details "
    end

    it "should raise an error if there's an endless loop" do
      infinite_file_system = Class.new do
        def read_template_file(template_path)
          "-{% include 'loop' %}"
        end
      end

      Liquid::Template.file_system = infinite_file_system.new

      expect {
        render!("{% include 'loop' %}")
      }.to raise_error(Liquid::StackLevelError)
    end

    it "should allow dynamically choosing templates" do
      render("{% include template %}", "template" => 'Test123').should == "Test123"
      render("{% include template %}", "template" => 'Test321').should == "Test321"

      data = {"template" => 'product', 'product' => { 'title' => 'Draft 151cm'}}
      render("{% include template for product %}", data).should == "Product: Draft 151cm "
    end
  end
end