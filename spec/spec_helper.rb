require 'rubygems'
require "bundler"
Bundler.setup

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))

# add lib to load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'locomotive_liquid'

require 'rspec'

# load support helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

