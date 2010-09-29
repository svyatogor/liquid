require 'spec_helper'

module Liquid
  describe "Liquid Parsing" do

    it "should render whitespace properly" do
      parse("  ").root.nodelist.should == ["  "]
    end

    describe %|"{{funk}}  "| do
      it{ parse(:subject).root.nodelist.should have(2).nodes }

      it "should parse to: Variable,String" do
        parse(:subject).root.nodelist[0].should be_an_instance_of(Liquid::Variable)
        parse(:subject).root.nodelist[1].should be_an_instance_of(String)
      end
    end

    describe %|"  {{funk}}"| do
      it{ parse(:subject).root.nodelist.should have(2).nodes }

      it "should parse to: String,Variable" do
        parse(:subject).root.nodelist[0].should be_an_instance_of(String)
        parse(:subject).root.nodelist[1].should be_an_instance_of(Liquid::Variable)
      end
    end

    describe %|"  {{funk}}  "| do
      it{ parse(:subject).root.nodelist.should have(3).nodes }

      it "should parse to: String,Variable,String" do
        parse(:subject).root.nodelist[0].should be_an_instance_of(String)
        parse(:subject).root.nodelist[1].should be_an_instance_of(Liquid::Variable)
        parse(:subject).root.nodelist[2].should be_an_instance_of(String)
      end
    end

    describe %|"  {{funk}} {{so}} {{brother}} "| do
      it{ parse(:subject).root.nodelist.should have(7).nodes }

      it "should parse to: String,Variable,String,Variable,String,Variable,String" do
        parse(:subject).root.nodelist[0].should be_an_instance_of(String)
        parse(:subject).root.nodelist[1].should be_an_instance_of(Liquid::Variable)
        parse(:subject).root.nodelist[2].should be_an_instance_of(String)
        parse(:subject).root.nodelist[3].should be_an_instance_of(Liquid::Variable)
        parse(:subject).root.nodelist[4].should be_an_instance_of(String)
        parse(:subject).root.nodelist[5].should be_an_instance_of(Liquid::Variable)
        parse(:subject).root.nodelist[6].should be_an_instance_of(String)
      end
    end

    describe %|"  {% comment %} {% endcomment %} "| do
      it{ parse(:subject).root.nodelist.should have(3).nodes }
      it "should parse to: String,Comment,String" do
        parse(:subject).root.nodelist[0].should be_an_instance_of(String)
        parse(:subject).root.nodelist[1].should be_an_instance_of(Liquid::Comment)
        parse(:subject).root.nodelist[2].should be_an_instance_of(String)
      end
    end

    context "when the custom tag 'somethingaweful' is defined" do
      before(:each) do
        Liquid::Template.register_tag('somethingaweful', Liquid::Block)
      end

      describe %|"{% somethingaweful %} {% endsomethingaweful %}"| do
        it "should parse successfully" do
          parse(:subject).root.nodelist.should have(1).nodes
        end
      end
    end

  end
end