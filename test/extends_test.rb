class ExtendsTest < Test::Unit::TestCase
  include Liquid

  class TestFileSystem
    def read_template_file(template_path)
      case template_path
      when "another_path"
        "Another path!"
      when "variable"
        "Hello, {{ name }}!"
      when "deep"
        "{% extends variable %}"
      else
        template_path
      end
    end
  end

  def setup
    Liquid::Template.file_system = TestFileSystem.new
  end

  def test_extends
    document = Template.parse("{% extends another_path %}")
    assert_equal 'Another path!', document.render({})
  end

  def test_extends_with_more
    document = Template.parse("{% extends another_path %} Hello!")
    assert_equal 'Another path!', document.render({})
  end

  def test_extends_var
    document = Template.parse("{% extends variable %}")
    assert_equal 'Hello, berto!', document.render({'name' => 'berto'})
  end

  def test_extends_deeper
    document = Template.parse("{% extends deep %}")
    assert_equal 'Hello, berto!', document.render({'name' => 'berto'})
  end
end