#!/usr/bin/ruby
# encoding: UTF-8

begin
  require 'rubygems'
  require 'yaml'
  require 'ridley'
  require 'chef/cookbook/metadata'
rescue LoadError => e
  raise "Missing gem #{e}"
end

# performs tests on the passed in cookbook
class ReaganTestVersion
  def initialize(cookbook)
    @config = YAML.load_file('config.yml')
    @cookbook = cookbook
  end

  # grab the version of the cookbook in the local metadata
  def check_commit_version
    metadata = Chef::Cookbook::Metadata.new
    metadata.from_file(File.join(@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook, 'metadata.rb'))
    metadata.version
  end

  # grab the most recent version of the cookbook on the chef server
  def check_server_version
    Ridley::Logging.logger.level = Logger.const_get 'ERROR'
    server_con = Ridley.new(
        server_url: @config['chef']['server_url'],
        client_name: @config['chef']['client_name'],
        client_key: @config['chef']['pem_path'],
        ssl: { verify: false }
      )
    server_con.cookbook.all[@cookbook][0]
  end

  # performs version update test
  # returns  true if version has been rev'd and false if not
  def test
    commit_v = check_commit_version
    serv_v = check_server_version
    updated = Gem::Version.new(serv_v) < Gem::Version.new(commit_v) ? true : false

    puts "Running cookbook version rev'd test:"
    puts "    Server version: #{serv_v}"
    puts "    Commit version: #{commit_v}"
    puts updated ? "    PASS: Metadata version has been rev'd" : "    FAIL: Metadata version has NOT been rev'd"
    updated
  end
end
