class ProductDrop < Liquid::Drop
  class TextDrop < Liquid::Drop
    def array
      ['text1', 'text2']
    end

    def text
      'text1'
    end
  end

  class CatchallDrop < Liquid::Drop
    def before_method(method)
      return 'method: ' << method
    end
  end

  def texts
    TextDrop.new
  end

  def catchall
    CatchallDrop.new
  end

  def context
    ContextDrop.new
  end

  protected
    def callmenot
      "protected"
    end
end