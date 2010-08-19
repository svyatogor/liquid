class BlockTagTest < Test::Unit::TestCase
  include Liquid

  class TestFileSystem
    def read_template_file(template_path)
      case template_path
      when "base"
        "Output / {% block content %}Hello, World!{% endblock %}"
      when "deep"
        "{% extends base %}{% block content %}Deep: {{block.super}}{% endblock %}"
      when "nested_and_deep"
        "{% extends base %}{% block content %}Deep: {{block.super}} -{% block inner %}FOO{% endblock %}-{% endblock %}"
      else
        template_path
      end
    end
  end

  def setup
    Liquid::Template.file_system = TestFileSystem.new
  end

  def test_extends
    document = Template.parse("{% extends base %}{% block content %}Hola, Mundo!{% endblock %}")
    rendered = document.render({})
    assert_equal 'Output / Hola, Mundo!', rendered
  end

  def test_block_super
    document = Template.parse("{% extends base %}{% block content %}Lorem ipsum: {{block.super}}{% endblock %}")
    rendered = document.render({})
    assert_equal 'Output / Lorem ipsum: Hello, World!', rendered
  end

  def test_deep_block_super
    document = Template.parse("{% extends deep %}{% block content %}Lorem ipsum: {{block.super}}{% endblock %}")
    rendered = document.render({})
    assert_equal 'Output / Lorem ipsum: Deep: Hello, World!', rendered
  end

  def test_nested_deep_blocks
    document = Template.parse("{% extends nested_and_deep %}{% block inner %}BAR{% endblock %}")
    rendered = document.render({})
    assert_equal 'Output / Deep: Hello, World! -BAR-', rendered
  end
end