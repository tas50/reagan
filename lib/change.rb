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
  require 'reagan'
  require 'rubygems'
  require 'octokit'
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

# determines changed files in the commit
class Change < Reagan
  attr_accessor :files
  def initialize
    @files = list_files_changed
  end

  def unique_cookbooks(files)
    cookbooks = []
    files.each do |file|
      path_array = file.split('/')
      cookbooks << path_array[1] if path_array[0].match('^cookbooks')
    end
    cookbooks.to_set
  end

  def files_from_pull(pull_changes)
    files = []
    pull_changes.each do |file|
      files << file[:filename]
    end
    files
  end

  def pull_num
    if @@config['flags']['pull']
      pull = @@config['flags']['pull']
    elsif ENV['ghprbPullId']
      pull = ENV['ghprbPullId']
    else
      fail 'Jenkins ghprbPullId environmental variable not set or --pull option not used.  Cannot continue'
    end
    pull
  end

  # return list of cookbooks changed either from override value or from polling github pull request
  def list_files_changed
    if @@config['flags']['cookbooks']
      @@config['flags']['cookbooks'].split(',')
    else
      pull = pull_num
      puts "Grabbing contents of pull request #{pull}\n"

      gh = Octokit::Client.new(:access_token => @@config['github']['auth_token'])

      pull_files = files_from_pull(gh.pull_request_files(@@config ['github']['repo'], pull))
      unique_cookbooks(pull_files)
    end
  end
end
