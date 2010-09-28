require 'rubygems'
require "bundler"
Bundler.setup

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'locomotive_liquid'

require 'rspec'

# support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

