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
    @files = files_to_test
  end

  # return hash of json files / cookbooks that have been changed
  def files_to_test
    if @@config['flags']['override_cookbooks']
      files_from_override
    else
      pull = pull_num
      puts "Grabbing contents of pull request #{pull}\n"
      hash_builder(query_gh(pull))
    end
  end

  # build a files hash based on the override cookbooks passed by the user
  def files_from_override
    files = {}
    files['json'] = []
    files['cookbooks'] = @@config['flags']['override_cookbooks'].split(',')
    files
  end

  # fetch pull num from either ENV or CLI param
  def pull_num
    if @@config['flags']['pull']
      pull = @@config['flags']['pull']
    elsif ENV['ghprbPullId']
      pull = ENV['ghprbPullId']
    else
      puts 'Jenkins ghprbPullId environmental variable not set or --pull option not used.  Cannot continue'
      exit 1
    end
    pull
  end

  # queries github for the files that have changed
  def query_gh(pull_num)
    gh = Octokit::Client.new(:access_token => @@config['github']['auth_token'])
    files_from_pull(gh.pull_request_files(@@config ['github']['repo'], pull_num))
  end

  # convert pull request response to array of changed files
  def files_from_pull(pull_changes)
    files = []
    pull_changes.each do |file|
      files << file[:filename]
    end
    files
  end

  # builds a hash of files / cookbooks that changed based on the pull data from GH
  def hash_builder(pull_files)
    files = {}
    files['json'] = []
    files['cookbooks'] = []
    cookbooks = []

    pull_files.each do |file|
      # populate json array if file is json
      files['json'] << file && next if file.match('.json$')

      # populate cookbooks array if filename starts with cookbooks
      cookbooks << file.split('/')[1]   if  file.match('^cookbooks')
    end
    # set cookbooks array to set to dedupe list of cookbooks
    files['cookbooks'] = cookbooks.to_set
    files
  end
end
