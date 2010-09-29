class EnumerableDrop < Liquid::Drop

  def size
    3
  end

  def each
    yield 1
    yield 2
    yield 3
  end
end
