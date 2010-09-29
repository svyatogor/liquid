require 'spec_helper'

describe "Liquid Rendering" do
  describe "Capture" do

    # capturing blocks content in a variable
    describe "assigning a capture block" do
      let(:template) do
        Liquid::Template.parse multiline_string(<<-END_LIQUID)
        |  {% capture 'var' %}test string{% endcapture %}
        |  {{var}}
        END_LIQUID
      end

      it "render the captured block" do
        template.render.strip.should == "test string"
      end
    end

    describe "capturing to a variable from outer scope (if existing)" do
      let(:template) do
        Liquid::Template.parse multiline_string(<<-END_LIQUID)
        |  {% assign var = '' %}
        |  {% if true %}
        |    {% capture var %}first-block-string{% endcapture %}
        |  {% endif %}
        |  {% if true %}
        |    {% capture var %}test-string{% endcapture %}
        |  {% endif %}
        |  {{var}}
        END_LIQUID
      end

      it "should render the captured variable" do
        template.render.strip.should == "test-string"
      end
    end

    describe "assigning from a capture block" do
      let(:template) do
        Liquid::Template.parse multiline_string(<<-END_LIQUID)
        |  {% assign first = '' %}
        |  {% assign second = '' %}
        |  {% for number in (1..3) %}
        |    {% capture first %}{{number}}{% endcapture %}
        |    {% assign second = first %}
        |  {% endfor %}
        |  {{ first }}-{{ second }}
        END_LIQUID
      end

      it "should render the captured variable" do
        template.render.strip.should == "3-3"
      end

    end

  end
end
