# encoding: UTF-8
#
# Author:: Tim Smith (<tim@cozy.co>)
# Copyright:: Copyright (c) 2014 Tim Smith
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

begin
  require 'rubygems'
  require 'ridley'
  require 'chef/cookbook/metadata'
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

# tests to make sure the version has been updated on the cookbook
class  TestVersion < Reagan
  def initialize(cookbook)
    @cookbook = cookbook
  end

  # grab the version of the cookbook in the local metadata
  def check_commit_version
    metadata = Chef::Cookbook::Metadata.new
    metadata.from_file(File.join(@@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook, 'metadata.rb'))
    metadata.version
  end

  # grab the most recent version of the cookbook on the chef server
  def check_server_version
    Ridley::Logging.logger.level = Logger.const_get 'ERROR'
    server_con = Ridley.new(
        server_url: @@config['chef']['server_url'],
        client_name: @@config['chef']['client_name'],
        client_key: @@config['chef']['pem_path'],
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
