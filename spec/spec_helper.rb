require 'rubygems'
require "bundler"
Bundler.setup

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))

# add lib to load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

# add fixtures to load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "fixtures"))

require 'locomotive_liquid'

require 'rspec'

# add support to load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "support"))

# load support helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


module Liquid
  module SpecHelpers
    def render(body, *args)
      Liquid::Template.parse(body).render(*args)
    end

    def render!(body, *args)
      Liquid::Template.parse(body).render!(*args)
    end

    def parse(body = nil)
      body = eval(subject) if body == :subject

      Liquid::Template.parse(body)
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

  end
end

Rspec.configure do |c|
  c.include Liquid::SpecHelpers
end