require 'spec_helper'

describe "Liquid Parsing" do
  describe "Block" do

    it "should render whitespace properly" do
      template = Liquid::Template.parse("  ")
      template.root.nodelist.should == ["  "]
    end

    let(:template) do
      Liquid::Template.parse(eval(subject))
    end

    describe %|"{{funk}}  "| do
      it{ template.root.nodelist.should have(2).nodes }

      it "should parse to: Variable,String" do
        template.root.nodelist[0].should be_an_instance_of(Liquid::Variable)
        template.root.nodelist[1].should be_an_instance_of(String)
      end
    end

    describe %|"  {{funk}}"| do
      it{ template.root.nodelist.should have(2).nodes }

      it "should parse to: String,Variable" do
        template.root.nodelist[0].should be_an_instance_of(String)
        template.root.nodelist[1].should be_an_instance_of(Liquid::Variable)
      end
    end

    describe %|"  {{funk}}  "| do
      it{ template.root.nodelist.should have(3).nodes }

      it "should parse to: String,Variable,String" do
        template.root.nodelist[0].should be_an_instance_of(String)
        template.root.nodelist[1].should be_an_instance_of(Liquid::Variable)
        template.root.nodelist[2].should be_an_instance_of(String)
      end
    end

    describe %|"  {{funk}} {{so}} {{brother}} "| do
      it{ template.root.nodelist.should have(7).nodes }

      it "should parse to: String,Variable,String,Variable,String,Variable,String" do
        template.root.nodelist[0].should be_an_instance_of(String)
        template.root.nodelist[1].should be_an_instance_of(Liquid::Variable)
        template.root.nodelist[2].should be_an_instance_of(String)
        template.root.nodelist[3].should be_an_instance_of(Liquid::Variable)
        template.root.nodelist[4].should be_an_instance_of(String)
        template.root.nodelist[5].should be_an_instance_of(Liquid::Variable)
        template.root.nodelist[6].should be_an_instance_of(String)
      end
    end

    describe %|"  {% comment %} {% endcomment %} "| do
      it{ template.root.nodelist.should have(3).nodes }
      it "should parse to: String,Comment,String" do
        template.root.nodelist[0].should be_an_instance_of(String)
        template.root.nodelist[1].should be_an_instance_of(Liquid::Comment)
        template.root.nodelist[2].should be_an_instance_of(String)
      end
    end

    context "when the custom tag 'somethingaweful' is defined" do
      before(:each) do
        Liquid::Template.register_tag('somethingaweful', Liquid::Block)
      end

      describe %|"{% somethingaweful %} {% endsomethingaweful %}"| do
        it "should parse successfully" do
          template.root.nodelist.should have(1).nodes
        end
      end
    end

  end
end