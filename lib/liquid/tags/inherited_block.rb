module Liquid

  # Blocks are used with the Extends tag to define
  # the content of blocks. Nested blocks are allowed.
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class InheritedBlock < Block
    Syntax = /(#{QuotedFragment}+)/

    attr_accessor :parent
    attr_reader :name

    def initialize(tag_name, markup, tokens, context)
      if markup =~ Syntax
        @name = $1
      else
        raise SyntaxError.new("Error in tag 'block' - Valid syntax: block [name]")
      end

      context[:current_block] = self

      super if tokens
    end

    def render(context)
      # puts "[BLOCK #{@name}|render] parent = #{@parent.inspect}"
      context.stack do
        context['block'] = InheritedBlockDrop.new(self)
        render_all(@nodelist, context)
      end
    end

    def end_tag
      context[:blocks] ||= {}

      block = context[:blocks][@name]

      if block
        # needed for the block.super statement
        # puts "[BLOCK #{@name}|end_tag] nodelist #{@nodelist.inspect}"
        block.add_parent(@nodelist)

        @parent = block.parent
        @nodelist = block.nodelist

        # puts "[BLOCK #{@name}|end_tag] direct parent #{block.parent.inspect}"
      else
        # register it
        # puts "[BLOCK #{@name}|end_tag] register it"
        context[:blocks][@name] = self
      end
    end

    def add_parent(nodelist)
      if @parent
        # puts "[BLOCK #{@name}|add_parent] go upper"
        @parent.add_parent(nodelist)
      else
        # puts "[BLOCK #{@name}|add_parent] create parent #{@tag_name}, #{@name}"
        @parent = self.class.new(@tag_name, @name, nil, {})
        @parent.nodelist = nodelist
      end
    end

    def call_super(context)
      # puts "[BLOCK #{@name}|call_super] #{parent.inspect}"
      if parent
        parent.render(context)
      else
        ''
      end
    end

  end

  class InheritedBlockDrop < Drop

    def initialize(block)
      @block = block
    end

    def super
      # puts "[InheritedBlockDrop] called"
      @block.call_super(@context)
    end

  end

  Template.register_tag('block', InheritedBlock)
end