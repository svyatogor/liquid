require 'spec_helper'

describe "Liquid Rendering" do
  describe "Table helpers " do

    describe "tablerow" do
      it "should render a table with rows of 3 columns each" do

        template = Liquid::Template.parse multiline_string(<<-END)
        | {% tablerow n in numbers cols: 3 %} {{ n }} {% endtablerow %}
        END

        template.render('numbers' => [1,2,3,4,5,6]).strip.should == multiline_string(<<-END).strip
        | <tr class="row1">
        | <td class="col1"> 1 </td><td class="col2"> 2 </td><td class="col3"> 3 </td></tr>
        | <tr class="row2"><td class="col1"> 4 </td><td class="col2"> 5 </td><td class="col3"> 6 </td></tr>
        END

      end

      it "should render an empty table row of columns" do
        template = Liquid::Template.parse multiline_string(<<-END)
        | {% tablerow n in numbers cols: 3 %} {{ n }} {% endtablerow %}
        END

        template.render('numbers' => []).should == "<tr class=\"row1\">\n</tr>\n"
      end

      it "should render a table with rows of 5 columns each" do
        template = Liquid::Template.parse multiline_string(<<-END)
        | {% tablerow n in numbers cols: 5 %} {{ n }} {% endtablerow %}
        END

        template.render('numbers' => [1,2,3,4,5,6]).strip.should == multiline_string(<<-END).strip
        | <tr class="row1">
        | <td class="col1"> 1 </td><td class="col2"> 2 </td><td class="col3"> 3 </td><td class="col4"> 4 </td><td class="col5"> 5 </td></tr>
        | <tr class="row2"><td class="col1"> 6 </td></tr>
        END
      end

      it "should provide a tablerowloop.col counter within the tablerow" do
        template = Liquid::Template.parse multiline_string(<<-END)
        | {% tablerow n in numbers cols: 2 %} {{ tablerowloop.col }} {% endtablerow %}
        END

        template.render('numbers' => [1,2,3,4,5,6]).strip.should == multiline_string(<<-END).strip
        | <tr class="row1">
        | <td class="col1"> 1 </td><td class="col2"> 2 </td></tr>
        | <tr class="row2"><td class="col1"> 1 </td><td class="col2"> 2 </td></tr>
        | <tr class="row3"><td class="col1"> 1 </td><td class="col2"> 2 </td></tr>
        END
      end

    end

  end
end