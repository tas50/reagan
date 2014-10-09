#!/usr/bin/ruby
# encoding: UTF-8

begin
  require 'rubygems'
  require 'yaml'
rescue LoadError => e
  raise "Missing gem #{e}"
end

# performs tests on the passed in cookbook
class ReaganTestKnife
  def initialize(cookbook)
    @config = YAML.load_file('config.yml')
    @cookbook = cookbook
  end

  # performs knife cookbook test
  # returns  true if  cookbook passed or false if it failed
  def test
    # grab the version of the cookbook in the local metadata
    result = system "knife cookbook test -o #{File.join(@config['jenkins']['workspace_dir'], 'cookbooks')} #{@cookbook} > /dev/null 2>&1"

    puts 'Running knife cookbook test:'
    puts result ? '    PASS: Knife cookbook test was successful' : 'FAIL: Knife cookbookk test was NOT successful'
    result
  end
end
