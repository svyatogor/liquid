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
  module RenderSpecHelper
    def render(body, data = {})
      Liquid::Template.parse(body).render(data)
    end
  end
end

Rspec.configure do |c|
  c.include Liquid::RenderSpecHelper
end