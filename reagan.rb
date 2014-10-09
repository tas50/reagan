#!/usr/bin/env ruby
#

# load the libs
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

begin
  require 'change'
  require 'test_knife'
  require 'test_version'
rescue LoadError => e
  raise "Missing lib #{e}"
end

# make sure the Github Pull Request plugin was used to pass in the pull ID
fail 'ghprbPullId environmental variable not set.  Cannot continue' unless ENV['ghprbPullId']

def pretty_print(string)
  puts "\n#{string}"
  string.length.times { printf '-' }
  puts "\n"
end

puts "Grabbing contents of pull request #{ENV['ghprbPullId']}\n"
cookbooks = ReaganChange.new.files

pretty_print('The following cookbooks were changed')
cookbooks.each { |cb| puts cb }

cookbooks.each do |cookbook|
  pretty_print("Testing cookbook #{cookbook}")
  ReaganTestVersion.new(cookbook).test
  ReaganTestKnife.new(cookbook).test
end
