class ContextDrop < Liquid::Drop

  def read_bar
    @context['bar']
  end

  def read_foo
    @context['foo']
  end

  def count_scopes
    @context.scopes.size
  end

  def scopes_as_array
    (1..@context.scopes.size).to_a
  end

  def loop_pos
    @context['forloop.index']
  end

  def break
    Breakpoint.breakpoint
  end

  def before_method(method)
    return @context[method]
  end
end