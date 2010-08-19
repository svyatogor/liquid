module Liquid

  # Extends allows designer to use template inheritance
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class Extends < Block
    Syntax = /(#{QuotedFragment}+)/

    def initialize(tag_name, markup, tokens, context)
      if markup =~ Syntax
        @template_name = $1
      else
        raise SyntaxError.new("Error in tag 'extends' - Valid syntax: extends [template]")
      end

      super

      context.merge!(:blocks => find_blocks(@nodelist))

      # puts "[EXTENDS #{@template_name}] blocks = #{context[:blocks].inspect}"

      parent_template = parse_parent_template(context)

      # replace the nodelist by the new one
      @nodelist = parent_template.root.nodelist
    end

    protected

    def find_blocks(nodelist, blocks = {})
      if nodelist && nodelist.any?
        nodelist.inject(blocks) do |b, node|
          if node.is_a?(Liquid::InheritedBlock)
            b[node.name] = node
          end
          if node.respond_to?(:nodelist)
            self.find_blocks(node.nodelist, b) # FIXME: find nested blocks too
          end
          b
        end
      end
      blocks
    end

    private

    def parse_parent_template(context)
      source = Template.file_system.read_template_file(@template_name)
      Template.parse(source, context)
    end



    def assert_missing_delimitation!
    end
  end

  Template.register_tag('extends', Extends)
end