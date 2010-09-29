require 'spec_helper'

describe "Liquid Methods" do

  class TestClassA
    liquid_methods :allowedA, :chainedB
    def allowedA
      'allowedA'
    end
    def restrictedA
      'restrictedA'
    end
    def chainedB
      TestClassB.new
    end
  end

  class TestClassB
    liquid_methods :allowedB, :chainedC
    def allowedB
      'allowedB'
    end
    def chainedC
      TestClassC.new
    end
  end

  class TestClassC
    liquid_methods :allowedC
    def allowedC
      'allowedC'
    end
  end

  class TestClassC::LiquidDropClass
    def another_allowedC
      'another_allowedC'
    end
  end


  before(:each) do
    @a = TestClassA.new
    @b = TestClassB.new
    @c = TestClassC.new
  end

  it "should create liquid drop classes" do
    TestClassA::LiquidDropClass.should_not be_nil
    TestClassB::LiquidDropClass.should_not be_nil
    TestClassC::LiquidDropClass.should_not be_nil
  end

  it "should respond to to_liquid" do
    @a.should respond_to(:to_liquid)
    @b.should respond_to(:to_liquid)
    @c.should respond_to(:to_liquid)
  end

  it "should return the liquid drop class" do
    @a.to_liquid.should be_an_instance_of(TestClassA::LiquidDropClass)
    @b.to_liquid.should be_an_instance_of(TestClassB::LiquidDropClass)
    @c.to_liquid.should be_an_instance_of(TestClassC::LiquidDropClass)
  end

  it "should respond to liquid methods" do
    @a.to_liquid.should respond_to(:allowedA)
    @a.to_liquid.should respond_to(:chainedB)

    @b.to_liquid.should respond_to(:allowedB)
    @b.to_liquid.should respond_to(:chainedC)

    @c.to_liquid.should respond_to(:allowedC)
    @c.to_liquid.should respond_to(:another_allowedC)
  end

  it "should not respond to restricted methods" do
    @a.to_liquid.should_not respond_to(:restricted)
  end

  it "should use regular objects as drops" do
    render('{{ a.allowedA }}', 'a' => @a).should == "allowedA"
    render("{{ a.chainedB.allowedB }}", 'a'=>@a).should == 'allowedB'
    render("{{ a.chainedB.chainedC.allowedC }}", 'a'=>@a).should == 'allowedC'
    render("{{ a.chainedB.chainedC.another_allowedC }}", 'a'=>@a).should == 'another_allowedC'
    render("{{ a.restricted }}", 'a'=>@a).should == ''
    render("{{ a.unknown }}", 'a'=>@a).should == ''
  end
end