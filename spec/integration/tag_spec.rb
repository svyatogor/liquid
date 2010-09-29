require 'spec_helper'

describe "Liquid Rendering" do
  describe "Tags" do

    describe "comment" do
      context "{% comment %}" do
        it "should not render comment blocks" do
          render('{%comment%}{%endcomment%}').should == ''
          render('{%comment%}{% endcomment %}').should == ''
          render('{% comment %}{%endcomment%}').should == ''
          render('{% comment %}{% endcomment %}').should == ''
          render('{%comment%}comment{%endcomment%}').should == ''
          render('{% comment %}comment{% endcomment %}').should == ''
        end

        it "should render the other content that isnt inside the comment block" do

          render(%|the comment block should be removed {%comment%} be gone.. {%endcomment%} .. right?|).should ==
                 %|the comment block should be removed  .. right?|

          render('foo{%comment%}comment{%endcomment%}bar').should == 'foobar'
          render('foo{% comment %}comment{% endcomment %}bar').should == 'foobar'
          render('foo{%comment%} comment {%endcomment%}bar').should == 'foobar'
          render('foo{% comment %} comment {% endcomment %}bar').should == 'foobar'

          render('foo {%comment%} {%endcomment%} bar').should == 'foo  bar'
          render('foo {%comment%}comment{%endcomment%} bar').should == 'foo  bar'
          render('foo {%comment%} comment {%endcomment%} bar').should == 'foo  bar'

          render('foo{%comment%}
                                           {%endcomment%}bar').should == "foobar"
        end
      end
    end

    describe "for" do
      describe "{% for item in collection %}" do
        it "should repeat the block for each item in the collection" do
          data = {'collection' => [1,2,3,4]}
          render('{%for item in collection%} yo {%endfor%}', data).should == ' yo  yo  yo  yo '

          data = {'collection' => [1,2]}
          render('{%for item in collection%}yo{%endfor%}', data).should == 'yoyo'

          data = {'collection' => [1]}
          render('{%for item in collection%} yo {%endfor%}', data).should == ' yo '

          data = {'collection' => [1,2]}
          render('{%for item in collection%}{%endfor%}', data).should == ''

          data = {'collection' => [1,2,3]}
          render('{%for item in collection%} yo {%endfor%}', data).should == " yo  yo  yo "
        end

        it "should allow access to the current item via {{item}}" do
          data = {'collection' => [1,2,3]}
          render('{%for item in collection%} {{item}} {%endfor%}', data).should == ' 1  2  3 '
          render('{% for item in collection %}{{item}}{% endfor %}', data).should == '123'
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == '123'

          data = {'collection' => ['a','b','c','d']}
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == 'abcd'

          data = {'collection' => ['a',' ','b',' ','c']}
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == 'a b c'

          data = {'collection' => ['a','','b','','c']}
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == 'abc'
        end

        it "should allow deep nesting" do
          data = {'array' => [[1,2],[3,4],[5,6]] }
          render('{%for item in array%}{%for i in item%}{{ i }}{%endfor%}{%endfor%}', data).should == '123456'
        end

        it "should expose {{forloop.name}} to get the name of the collection" do
          data = {'collection' => [1] }
          render("{%for item in collection%} {{forloop.name}} {%endfor%}", data).should == " item-collection "
        end

        it "should expose {{forloop.length}} for the overall size of the collection being looped" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.length}} {%endfor%}", data).should == " 3  3  3 "
        end

        it "should expose {{forloop.index}} for the current item's position in the collection (1 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.index}} {%endfor%}", data).should == " 1  2  3 "
        end

        it "should expose {{forloop.index0}} for the current item's position in the collection (0 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.index0}} {%endfor%}", data).should == " 0  1  2 "
        end

        it "should expose {{forloop.rindex}} for the number of items remaining in the collection (1 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.rindex}} {%endfor%}", data).should == " 3  2  1 "
        end

        it "should expose {{forloop.rindex0}} for the number of items remaining in the collection (0 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.rindex0}} {%endfor%}", data).should == " 2  1  0 "
        end

        it "should expose {{forloop.first}} for the first item in the collection" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {% if forloop.first %}y{% else %}n{% endif %} {%endfor%}", data).should == " y  n  n "
        end

        it "should expose {{forloop.last}} for the last item in the collection" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {% if forloop.last %}y{% else %}n{% endif %} {%endfor%}", data).should == " n  n  y "
        end
      end

      describe "{% for item in collection reversed %}" do
        it "should reverse the loop" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection reversed%}{{item}}{%endfor%}", data).should == "321"
        end
      end

      context "with limit and offset" do
        let(:data) do
          {'collection' => [1,2,3,4,5,6,7,8,9,0] }
        end

        describe "{% for item in collection limit: 4 %}" do
          it "should only cycle through the first 4 items of the collection" do
            render("{%for item in collection limit:4%}{{item}}{%endfor%}", data).should  == "1234"
            render("{%for item in collection limit: 4%}{{item}}{%endfor%}", data).should == "1234"
          end
        end

        describe "{% for item in collection offset:8 %}" do
          it "should cycle throughthe collection starting on the 9th item" do
            render("{%for item in collection offset:8%}{{item}}{%endfor%}", data).should  == "90"
          end
        end

        describe "{% for item in collection limit:4 offset:2}" do
          it "should only cycle through the 4 items of the collection, starting on the 3rd item" do
            render("{%for item in collection limit:4 offset:2 %}{{item}}{%endfor%}", data).should == "3456"
            render("{%for item in collection limit: 4 offset: 2 %}{{item}}{%endfor%}", data).should == "3456"
          end

          it "{% for item in collection limit:limit offset:offset}" do
            data.merge! 'limit' => '4', 'offset' => '2'
            render("{%for item in collection limit:limit offset:offset %}{{item}}{%endfor%}", data).should == "3456"
            render("{%for item in collection limit: limit offset: offset %}{{item}}{%endfor%}", data).should == "3456"
          end
        end

        describe "{% for item in collection offset:continue limit: 3}" do
          it "should resume the iteration from where it ended earlier" do

            output = render multiline_string(<<-END), data
            | {%for i in collection limit:3 %}{{i}}{%endfor%}
            | next
            | {%for i in collection offset:continue limit:3 %}{{i}}{%endfor%}
            | next
            | {%for i in collection offset:continue limit:3 %}{{i}}{%endfor%}
            END

            output.should == multiline_string(<<-END)
            | 123
            | next
            | 456
            | next
            | 789
            END
          end
        end


        describe "edge cases" do
          context "limit: -1" do
            it "should ignore the limit" do
              render("{%for item in collection limit:-1 offset:5 %}{{item}}{%endfor%}", data).should == "67890"
            end
          end

          context "offset: -1" do
            it "should ignore the offset" do
              render("{%for item in collection limit:1 offset:-1 %}{{item}}{%endfor%}", data).should == "1"
            end
          end

          context "offset: 100" do
            it "should render an empty string" do
              render("{%for item in collection limit:1 offset:100 %} {{item}} {%endfor%}", data).should == ""
            end
          end

          context "resume with big limit" do
            it "should complete the rest of the items" do
              output = render multiline_string(<<-END), data
              | {%for i in collection limit:3 %}{{i}}{%endfor%}
              | next
              | {%for i in collection offset:continue limit:10000 %}{{i}}{%endfor%}
              END

              output.should == multiline_string(<<-END)
              | 123
              | next
              | 4567890
              END
            end
          end

          context "resume with big offset" do
            it "should complete the rest of the items" do
              output = render multiline_string(<<-END), data
              | {%for i in collection limit:3 %}{{i}}{%endfor%}
              | next
              | {%for i in collection offset:continue offset:10000 %}{{i}}{%endfor%}
              END

              output.should == multiline_string(<<-END)
              | 123
              | next
              | |
              END
            end
          end
        end
      end

      context "{% for item in (1..3) %}" do
        it "should repeat the block for each item in the range" do
          render('{%for item in (1..3) %} {{item}} {%endfor%}').should == ' 1  2  3 '
        end
      end

      context "{% ifchanged %}" do
        it "should render the block only if the for item is different than the last" do
          data = {'array' => [ 1, 1, 2, 2, 3, 3] }
          render('{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',data).should == '123'

          data = {'array' => [ 1, 1, 1, 1] }
          render('{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',data).should == '1'

        end
      end

    end


  end
end