#!/usr/bin/env ruby
require 'rubygems'

require "bundler"
Bundler.setup

require 'rake'
require 'rake/gempackagetask'

require "rspec"
require "rspec/core/rake_task"

Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

Rspec::Core::RakeTask.new('spec:progress') do |spec|
  spec.rspec_opts = %w(--format progress)
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec

gemspec = eval(File.read('locomotive_liquid.gemspec'))
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "build the gem and release it to rubygems.org"
task :release => :gem do
  sh "gem push pkg/locomotive_liquid-#{gemspec.version}.gem"
end

namespace :profile do

  task :default => [:run]

  desc "Run the liquid profile/perforamce coverage"
  task :run do

    ruby "performance/shopify.rb"

  end

  desc "Run KCacheGrind"
  task :grind => :run  do
    system "kcachegrind /tmp/liquid.rubyprof_calltreeprinter.txt"
  end
end

