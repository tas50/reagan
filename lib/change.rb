#!/usr/bin/ruby
# encoding: UTF-8

begin
  require 'rubygems'
  require 'octokit'
  require 'yaml'
rescue LoadError => e
  raise "Missing gem #{e}"
end

# determines changed files in the commit
class ReaganChange
  attr_accessor :files
  def initialize
    @config = YAML.load_file('config.yml')
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

  def list_files_changed
    gh = Octokit::Client.new(:access_token => @config['github'] ['auth_token'])

    pull_files = files_from_pull(gh.pull_request_files(@config ['github']['repo'], ENV['ghprbPullId']))
    unique_cookbooks(pull_files)
  end
end
