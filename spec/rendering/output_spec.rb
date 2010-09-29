require 'spec_helper'



describe "Liquid Rendering" do
  describe "Basic Output" do

    let(:filters) do
      {:filters => [FunnyFilter, HtmlFilter]}
    end

    let(:data) do
      {
        'best_cars' => 'bmw',
        'car' => {'bmw' => 'good', 'gm' => 'bad'}
      }
    end

    def render(text)
      super(text, data, filters)
    end

    it "should render a variable's value" do
      render(' {{best_cars}} ').should == " bmw "
    end

    it "should render a traversed variable's value" do
      render(' {{car.bmw}} {{car.gm}} {{car.bmw}} ').should == " good bad good "
    end

    module FunnyFilter
      def make_funny(input)
        'LOL'
      end
    end

    it "should allow piping to activate filters" do
      render(' {{ car.gm | make_funny }} ').should == ' LOL '
    end

    module FunnyFilter
      def cite_funny(input)
        "LOL: #{input}"
      end
    end

    it "should allow filters to read the input" do
      render(' {{ car.gm | cite_funny }} ').should == " LOL: bad "
    end

    module FunnyFilter
      def add_smiley(input, smiley = ":-)")
        "#{input} #{smiley}"
      end
    end

    it "should allow filters to take in parameters" do
      render(' {{ car.gm | add_smiley: ":-(" }} ').should ==
             ' bad :-( '

      render(' {{ car.gm | add_smiley : ":-(" }} ').should ==
             ' bad :-( '

      render(' {{ car.gm | add_smiley: \':-(\' }} ').should ==
             ' bad :-( '
    end

    it "should allow filters with no parameters and a default argument" do
      render(' {{ car.gm | add_smiley }} ').should ==
             ' bad :-) '
    end

    it "should allow multiple filters with parameters" do
      render(' {{ car.gm | add_smiley : ":-(" | add_smiley : ":-(" }} ').should ==
             ' bad :-( :-( '
    end

    module FunnyFilter
      def add_tag(input, tag = "p", id = "foo")
        %|<#{tag} id="#{id}">#{input}</#{tag}>|
      end
    end

    it "should allow filters with multiple parameters" do
      render(' {{ car.gm | add_tag : "span", "bar"}} ').should ==
             ' <span id="bar">bad</span> '
    end

    it "should allow filters with variable parameters" do
      render(' {{ car.gm | add_tag : "span", car.bmw }} ').should ==
             ' <span id="good">bad</span> '
    end

    module HtmlFilter
      def paragraph(input)
        "<p>#{input}</p>"
      end

      def link_to(name, url)
        %|<a href="#{url}">#{name}</a>|
      end
    end

    it "should allow multiple chained filters" do
      render(' {{ best_cars | cite_funny | link_to: "http://www.google.com" | paragraph }} ').should ==
             ' <p><a href="http://www.google.com">LOL: bmw</a></p> '
    end

  end
end