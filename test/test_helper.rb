#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__)+ '/extra')

require 'test/unit'
require 'test/unit/assertions'
require 'caller'
require 'breakpoint'
require File.dirname(__FILE__) + '/../lib/liquid'


module Test
  module Unit
    module Assertions
        include Liquid
        def assert_template_result(expected, template, assigns={}, message=nil)
          assert_equal expected, Template.parse(template).render(assigns)
        end
    end
  end
end

def print_child(node, depth = 0)
  information = (case node
    when Liquid::InheritedBlock
      "Liquid::InheritedBlock #{node.object_id} / #{node.name} / #{!node.parent.nil?} / #{node.nodelist.first.inspect}"
  else
    node.class.name
  end)

  puts information.insert(0, ' ' * (depth * 2))
  if node.respond_to?(:nodelist)
    node.nodelist.each do |node|
      print_child node, depth + 1
    end
  end
end