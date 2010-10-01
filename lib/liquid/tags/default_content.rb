module Liquid

  # InheritedContent pulls out the content from child templates that isnt defined in blocks
  #
  #  {% defaultcontent %}
  #
  class DefaultContent < Tag
    def initialize(tag_name, markup, tokens, context)
      super
    end

    def render(context)
      context.stack do
        "HELLO"
      end
    end
  end


  Template.register_tag('defaultcontent', DefaultContent)
end