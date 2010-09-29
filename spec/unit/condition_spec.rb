require 'spec_helper'

module Liquid
  describe Condition do
    before(:each) do
      @context = Context.new
    end

    # simple wrapper around CheckCondition evaluate
    def check_condition(*args)
      Condition.new(*args).evaluate(@context)
    end


    it "should check basic equality conditions" do
      check_condition("1", "==", "2").should be_false
      check_condition("1", "==", "1").should be_true
    end

    context "Default Operators (==, !=, <>, <, >, >=, <=)" do
      it "should evaluate true when appropriate" do
        check_condition('1', '==', '1').should be_true
        check_condition('1', '!=', '2').should be_true
        check_condition('1', '<>', '2').should be_true
        check_condition('1', '<',  '2').should be_true
        check_condition('2', '>',  '1').should be_true
        check_condition('1', '>=', '1').should be_true
        check_condition('2', '>=', '1').should be_true
        check_condition('1', '<=', '2').should be_true
        check_condition('1', '<=', '1').should be_true
      end

      it "should evaluate false when appropriate" do
        check_condition('1', '==', '2').should be_false
        check_condition('1', '!=', '1').should be_false
        check_condition('1', '<>', '1').should be_false
        check_condition('1', '<',  '0').should be_false
        check_condition('2', '>',  '4').should be_false
        check_condition('1', '>=', '3').should be_false
        check_condition('2', '>=', '4').should be_false
        check_condition('1', '<=', '0').should be_false
        check_condition('1', '<=', '0').should be_false
      end
    end

    context %{"contains"} do

      context "when operating on strings" do
        it "should evaluate to true when appropriate" do
          check_condition("'bob'", 'contains', "'o'").should be_true
          check_condition("'bob'", 'contains', "'b'").should be_true
          check_condition("'bob'", 'contains', "'bo'").should be_true
          check_condition("'bob'", 'contains', "'ob'").should be_true
          check_condition("'bob'", 'contains', "'bob'").should be_true
        end

        it "should evaluate to false when appropriate" do
          check_condition("'bob'", 'contains', "'bob2'").should be_false
          check_condition("'bob'", 'contains', "'a'").should be_false
          check_condition("'bob'", 'contains', "'---'").should be_false
        end
      end

      context "when operating on arrays" do
        before(:each) do
          @context['array'] = [1,2,3,4,5]
        end

        it "should evaluate to true when appropriate" do
          check_condition("array", "contains", "1").should be_true
          check_condition("array", "contains", "2").should be_true
          check_condition("array", "contains", "3").should be_true
          check_condition("array", "contains", "4").should be_true
          check_condition("array", "contains", "5").should be_true
        end

        it "should evaluate to false when appropriate" do
          check_condition("array", "contains", "0").should be_false
          check_condition("array", "contains", "6").should be_false
        end

        it "should not equate strings to integers" do
          check_condition("array", "contains", "5").should be_true
          check_condition("array", "contains", "'5'").should be_false
        end
      end

      it "should return false for all nil operands" do
        check_condition("not_assigned", "contains", "0").should be_false
        check_condition("0", "contains", "not_assigned").should be_false
      end
    end

    describe %{Chaining with "or"} do
      before(:each) do
        @condition = Condition.new("1", "==", "2")
        @condition.evaluate.should be_false
      end

      it "should return true when it you add a single condition that evaluates to true" do
        @condition.or Condition.new("2", "==", "1")
        @condition.evaluate.should be_false

        @condition.or Condition.new("1", "==", "1")
        @condition.evaluate.should be_true
      end
    end

    describe %{Chaining with "and"} do
      before(:each) do
        @condition = Condition.new("1", "==", "1")
        @condition.evaluate.should be_true
      end

      it "should return false when it you add a single condition that evaluates to false" do
        @condition.and Condition.new("2", "==", "2")
        @condition.evaluate.should be_true

        @condition.and Condition.new("2", "==", "1")
        @condition.evaluate.should be_false
      end
    end

    describe "Custom proc operator" do
      before(:each) do
        Condition.operators["starts_with"] = Proc.new { |cond, left, right| left =~ %r{^#{right}}}
      end

      it "should use the assigned proc to evalue the operator" do
        check_condition("'bob'", "starts_with", "'b'").should be_true
        check_condition("'bob'", "starts_with", "'o'").should be_false
      end

      after(:each) do
        Condition.operators.delete('starts_with')
      end
    end
  end
end