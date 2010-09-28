require 'spec_helper'

module Liquid
  describe Context do

    before(:each) do
      @context = Liquid::Context.new
    end

    it "should allow assigning variables" do
      @context['string'] = 'string'
      @context['string'].should == 'string'

      @context['num'] = 5
      @context['num'].should == 5

      @context['time'] = Time.parse('2006-06-06 12:00:00')
      @context['time'].should == Time.parse('2006-06-06 12:00:00')

      @context['date'] = Date.today
      @context['date'].should == Date.today

      now = DateTime.now
      @context['datetime'] = now
      @context['datetime'].should == now

      @context['bool'] = true
      @context['bool'].should == true

      @context['bool'] = false
      @context['bool'].should == false

      @context['nil'] = nil
      @context['nil'].should == nil
    end

    it "should return nil for variables that don't exist" do
      @context["does_not_exist"].should == nil
    end

    it "should return the size of an array" do
      @context['numbers'] = [1,2,3,4]
      @context['numbers.size'].should == 4
    end

    it "should return the size of an hash" do
      @context['numbers'] = {1 => 1,2 => 2,3 => 3,4 => 4}
      @context['numbers.size'].should == 4
    end

    it "should allow acess on a hash value by key" do
      @context['numbers'] = {1 => 1,2 => 2,3 => 3,4 => 4, 'size' => 1000}
      @context['numbers.size'].should == 1000
    end

    it "should handle hyphenated variables" do
      @context["oh-my"] = "godz"
      @context["oh-my"].should == "godz"
    end

    it "should merge data" do
      @context.merge("test" => "test")
      @context["test"].should == "test"

      @context.merge("test" => "newvalue", "foo" => "bar")
      @context["test"].should == "newvalue"
      @context["foo"].should == "bar"
    end

    describe "filters" do
      before(:each) do
        filter = Module.new do
          def exclaim(output)
            output + "!!!"
          end
        end
        @context.add_filters(filter)
      end

      it "should invoke a filter if found" do
        @context.invoke(:exclaim, "hi").should == "hi!!!"
      end

      it "should ignore a filter thats not found" do
        local = Liquid::Context.new
        local.invoke(:exclaim, "hi").should == "hi"
      end

      it "should override a global filter" do
        global = Module.new do
          def notice(output)
            "Global #{output}"
          end
        end

        local = Module.new do
          def notice(output)
            "Local #{output}"
          end
        end

        Template.register_filter(global)
        Template.parse("{{'test' | notice }}").render.should == "Global test"
        Template.parse("{{'test' | notice }}").render({}, :filters => [local]).should == "Local test"
      end

      it "should only include intended filters methods" do
        filter = Module.new do
          def hi(output)
            output + ' hi!'
          end
        end

        local = Context.new
        methods_before = local.strainer.methods.map { |method| method.to_s }
        local.add_filters(filter)
        methods_after = local.strainer.methods.map { |method| method.to_s }
        methods_after.sort.should == (methods_before+["hi"]).sort
      end
    end

    describe "scopes" do
      it "should handle scoping properly" do
        expect {
          @context.push
          @context.pop
        }.to_not raise_exception

        expect {
          @context.pop
        }.to raise_exception(Liquid::ContextError)

        expect {
          @context.push
          @context.pop
          @context.pop
        }.to raise_exception(Liquid::ContextError)
      end

      it "should allow access to items from outer scope within an inner scope" do
        @context["test"] = "test"
        @context.push
        @context["test"].should == "test"
        @context.pop
        @context["test"].should == "test"
      end

      it "should not allow access to items from inner scope with an outer scope" do
        @context.push
        @context["test"] = 'test'
        @context["test"].should == "test"
        @context.pop
        @context["test"].should == nil
      end
    end

    describe "literals" do
      it "should recognize boolean keywords" do
        @context["true"].should == true
        @context["false"].should == false
      end

      it "should recognize integers and floats" do
        @context["100"].should == 100
        @context[%Q{100.00}].should == 100.00
      end

      it "should recognize strings" do
        @context[%{"hello!"}].should == "hello!"
        @context[%{'hello!'}].should == "hello!"
      end

      it "should recognize ranges" do
        @context.merge( "test" => '5' )
        @context['(1..5)'].should == (1..5)
        @context['(1..test)'].should == (1..5)
        @context['(test..test)'].should == (5..5)
      end
    end

    context "hierarchical data" do
      it "should allow access to hierarchical data" do
        @context["hash"] = {"name" => "tobi"}
        @context['hash.name'].should == "tobi"
        @context["hash['name']"].should == "tobi"
        @context['hash["name"]'].should == "tobi"
      end

      it "should allow access to arrays" do
        @context["test"] = [1,2,3,4,5]

        @context["test[0]"].should == 1
        @context["test[1]"].should == 2
        @context["test[2]"].should == 3
        @context["test[3]"].should == 4
        @context["test[4]"].should == 5
      end

      it "should allow access to an array within a hash" do
        @context['test'] = {'test' => [1,2,3,4,5]}
        @context['test.test[0]'].should == 1

        # more complex
        @context['colors'] = {
         'Blue'    => ['003366','336699', '6699CC', '99CCFF'],
         'Green'   => ['003300','336633', '669966', '99CC99'],
         'Yellow'  => ['CC9900','FFCC00', 'FFFF99', 'FFFFCC'],
         'Red'     => ['660000','993333', 'CC6666', 'FF9999']
        }
        @context['colors.Blue[0]'].should == '003366'
        @context['colors.Red[3]'].should == 'FF9999'
      end

      it "should allow access to a hash within an array" do
        @context['test'] = [{'test' => 'worked'}]
        @context['test[0].test'].should == "worked"
      end

      it "should provide first and last helpers for arrays" do
        @context['test'] = [1,2,3,4,5]

        @context['test.first'].should == 1
        @context['test.last'].should == 5

        @context['test'] = {'test' => [1,2,3,4,5]}

        @context['test.test.first'].should == 1
        @context['test.test.last'].should == 5

        @context['test'] = [1]
        @context['test.first'].should == 1
        @context['test.last'].should == 1
      end

      it "should allow arbitrary depth chaining of hash and array notation" do
        @context['products'] = {'count' => 5, 'tags' => ['deepsnow', 'freestyle'] }
        @context['products["count"]'].should == 5
        @context['products["tags"][0]'].should == "deepsnow"
        @context['products["tags"].first'].should == "deepsnow"

        @context['product'] = {'variants' => [ {'title' => 'draft151cm'}, {'title' => 'element151cm'}  ]}
        @context['product["variants"][0]["title"]'].should == "draft151cm"
        @context['product["variants"][1]["title"]'].should == "element151cm"
        @context['product["variants"][0]["title"]'].should == "draft151cm"
        @context['product["variants"].last["title"]'].should == "element151cm"
      end

      it "should allow variable access with hash notation" do
        @context.merge("foo" => "baz", "bar" => "foo")
        @context['["foo"]'].should == "baz"
        @context['[bar]'].should == "baz"
      end

      it "should allow hash access with hash variables" do
        @context['var'] = 'tags'
        @context['nested'] = {'var' => 'tags'}
        @context['products'] = {'count' => 5, 'tags' => ['deepsnow', 'freestyle'] }

        @context['products[var].first'].should == "deepsnow"
        @context['products[nested.var].last'].should == 'freestyle'
      end

      it "should use hash notification only for hash access" do
        @context['array'] = [1,2,3,4,5]
        @context['hash'] = {'first' => 'Hello'}

        @context['array.first'].should == 1
        @context['array["first"]'].should == nil
        @context['hash["first"]'].should == "Hello"
      end

      it "should allow helpers (such as first and last) in the middle of a callchain" do
        @context['product'] = {'variants' => [ {'title' => 'draft151cm'}, {'title' => 'element151cm'}  ]}

        @context['product.variants[0].title'].should == 'draft151cm'
        @context['product.variants[1].title'].should == 'element151cm'
        @context['product.variants.first.title'].should == 'draft151cm'
        @context['product.variants.last.title'].should == 'element151cm'
      end
    end

    describe "Custom Object with a to_liquid method" do
      class HundredCentes
        def to_liquid
          100
        end
      end

      it "should resolve to whatever to_liquid returns from the object" do
        @context["cents"] = HundredCentes.new
        @context["cents"].should == 100
      end

      it "should allow access to the custom object within a hash" do
        @context.merge( "cents" => { 'amount' => HundredCentes.new} )
        @context['cents.amount'].should == 100

        @context.merge( "cents" => { 'cents' => { 'amount' => HundredCentes.new} } )
        @context['cents.cents.amount'].should == 100
      end
    end

    describe "Liquid Drops" do
      class CentsDrop < Liquid::Drop
        def amount
          HundredCentes.new
        end

        def non_zero?
          true
        end
      end

      it "should allow access to the drop's methods" do
        @context.merge( "cents" => CentsDrop.new )
        @context['cents.amount'].should == 100
      end

      it "should allow access to the drop's methods when nested in a hash" do
        @context.merge( "vars" => {"cents" => CentsDrop.new} )
        @context['vars.cents.amount'].should == 100
      end

      it "should allow access to the a drop's methods that ends in a question mark" do
        @context.merge( "cents" => CentsDrop.new )
        @context['cents.non_zero?'].should be_true
      end

      it "should allow access to drop methods even when deeply nested" do
        @context.merge( "cents" => {"cents" => CentsDrop.new} )
        @context['cents.cents.amount'].should == 100

        @context.merge( "cents" => { "cents" => {"cents" => CentsDrop.new}} )
        @context['cents.cents.cents.amount'].should == 100
      end

      class ContextSensitiveDrop < Liquid::Drop
        def test
          @context['test']
        end

        def read_test
          @context["test"]
        end
      end

      it "should allow access to the current context from within a drop" do
        @context.merge( "test" => '123', "vars" => ContextSensitiveDrop.new )
        @context["vars.test"].should == "123"
        @context["vars.read_test"].should == "123"
      end

      it "should allow access to the current context even when nested in a hash" do
        @context.merge( "test" => '123', "vars" => {"local" => ContextSensitiveDrop.new }  )
        @context['vars.local.test'].should == "123"
        @context['vars.local.read_test'].should == "123"
      end


      class CounterDrop < Liquid::Drop
        def count
          @count ||= 0
          @count += 1
        end
      end

      it "should trigger a drop's autoincrementing variable" do
        @context['counter'] = CounterDrop.new

        @context['counter.count'].should == 1
        @context['counter.count'].should == 2
        @context['counter.count'].should == 3
      end

      it "should trigger a drop's autoincrementing variable using hash syntax " do
        @context['counter'] = CounterDrop.new

        @context['counter["count"]'].should == 1
        @context['counter["count"]'].should == 2
        @context['counter["count"]'].should == 3
      end
    end

    context "lambas and procs" do
      it "should trigger a proc if accessed as a variable" do
        @context["dynamic1"] = Proc.new{ "Hello" }
        @context['dynamic1'].should == "Hello"

        @context["dynamic2"] = proc{ "Hello" }
        @context['dynamic2'].should == "Hello"

      end

      it "should trigger a proc within a hash" do
        @context["dynamic"] = {"lambda" => proc{ "Hello" }}
        @context["dynamic.lambda"].should == "Hello"
      end

      it "should trigger a proc within an array" do
        @context['dynamic'] = [1,2, proc { 'Hello' } ,4,5]
        @context['dynamic[2]'].should == "Hello"
      end

      it "should trigger the proc only the first time it's accessed" do
        counter = 0
        @context["dynamic"] = proc{ "Hello #{counter += 1}" }
        @context['dynamic'].should == "Hello 1"
        @context['dynamic'].should == "Hello 1"
        @context['dynamic'].should == "Hello 1"
      end

      it "should trigger the proc within a hash only the first time it's accessed" do
        counter = 0
        @context["dynamic"] = {"lambda" => proc{ "Hello #{counter += 1}" } }
        @context['dynamic.lambda'].should == "Hello 1"
        @context['dynamic.lambda'].should == "Hello 1"
        @context['dynamic.lambda'].should == "Hello 1"
      end

      it "should trigger the proc within an array only the first time it's accessed" do
        counter = 0
        @context["dynamic"] = [1, 2, proc{ "Hello #{counter += 1}" }, 4]
        @context['dynamic[2]'].should == "Hello 1"
        @context['dynamic[2]'].should == "Hello 1"
        @context['dynamic[2]'].should == "Hello 1"
      end

      it "should allow access to context from within proc" do
        @context.registers[:magic] = 345392
        @context['magic'] = proc { @context.registers[:magic] }
        @context['magic'].should == 345392
      end
    end


    context "to_liquid returning a drop" do
      class Category < Liquid::Drop
        attr_accessor :name

        def initialize(name)
          @name = name
        end

        def to_liquid
          CategoryDrop.new(self)
        end
      end

      class CategoryDrop
        attr_accessor :category, :context
        def initialize(category)
          @category = category
        end
      end

      it "should return a drop" do
        @context['category'] = Category.new("foobar")
        @context['category'].should be_an_instance_of(CategoryDrop)
        @context['category'].context.should == @context
      end

      class ArrayLike
        def fetch(index)
        end

        def [](index)
          @counts ||= []
          @counts[index] ||= 0
          @counts[index] += 1
        end

        def to_liquid
          self
        end
      end

    end
  end
end

