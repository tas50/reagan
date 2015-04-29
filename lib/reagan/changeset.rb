# encoding: UTF-8
#
# Author:: Tim Smith (<tim@cozy.co>)
# Copyright:: Copyright (c) 2014-2015 Tim Smith
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
  require 'octokit'
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

module Reagan
  # determines changed files in the commit
  class ChangeSet
    def self::files
      @files ||= changed_files
    end

    # return hash of chef objects that have been changed
    def self::changed_files
      if Config.settings['flags']['override_cookbooks']
        files_from_override
      else
        pull = Config.settings['flags']['pull']
        puts "Grabbing contents of pull request #{pull}\n"
        hash_builder(query_gh(pull))
      end
    end

    # check if the changeset is empty
    def self::empty?
      objects_updated = false
      %w(cookbooks roles environments data_bags).each do |object|
        objects_updated = true unless files[object].empty?
      end
      !objects_updated
    end

    # build a files hash based on the override cookbooks passed by the user
    def self::files_from_override
      files = {}
      %w(environments roles data_bags).each { |object| files[object] = {} }

      # ensure that the passed cookbooks exist in the workspace first
      cookbooks = []
      Config.settings['flags']['override_cookbooks'].each do |cb|
        if object_still_exists(::File.join('cookbooks/', cb))
          cookbooks << cb
        else
          puts "Skipping override cookbook #{cb} as it does not exist in the workspace"
        end
      end

      files['cookbooks'] = cookbooks
      files
    end

    # queries github for the files that have changed
    def self::query_gh(pull_num)
      Octokit.auto_paginate = true # avoids issues with large commits
      Octokit.api_endpoint = Config.settings['github']['api_endpoint'] || 'https://api.github.com'
      gh = Octokit::Client.new(access_token: Config.settings['github']['auth_token'])
      files_from_pull(gh.pull_request_files(Config.settings['github']['repo'], pull_num))
      rescue
        puts 'Failed to query pull request contents from Github. Check the api_endpoint, repo, and token.'
        exit 1
    end

    # convert pull request response to array of changed files
    def self::files_from_pull(pull_changes)
      files = []
      pull_changes.each do |file|
        files << file[:filename]
      end
      files
    end

    # check to see if the file exists in the workspace so we don't test deleted objects
    def self::object_still_exists(file)
      ::File.exist?(::File.join(Config.settings['jenkins']['workspace_dir'], file))
    end

    # builds a hash of files / cookbooks that changed based on the pull data from GH
    def self::hash_builder(pull_files)
      files = {}
      %w(environments roles data_bags cookbooks).each { |object| files[object] = [] }
      cookbooks = []

      pull_files.each do |file|
        files['environments'] << file && next if file.match('^environments') && object_still_exists(file)
        files['roles'] << file && next if file.match('^roles') && object_still_exists(file)
        files['data_bags'] << file && next if file.match('^data_bags') && object_still_exists(file)
        cookbooks << file.split('/')[1] if file.match('^cookbooks') && object_still_exists(::File.join('cookbooks/', file.split('/')[1]))
      end
      # set cookbooks array to set to dedupe list of cookbooks
      files['cookbooks'] = cookbooks.to_set
      files
    end
  end
end
