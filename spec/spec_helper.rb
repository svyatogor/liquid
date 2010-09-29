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


  end
end

Rspec.configure do |c|
  c.include Liquid::SpecHelpers
end