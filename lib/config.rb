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
  require 'yaml'
  require 'optparse'
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

module Reagan
  # builds a single config from passed flags, yaml config, and knife.rb
  class Config
    attr_accessor :settings
    def initialize
      @flags = flag_parser
      @config_file = load_config_file
      @settings = build_config
    end

    # grabs the flags passed in via command line
    def flag_parser
      flags = { :pull => nil, :override_cookbooks => nil, :config => '/etc/reagan.yml', :print_config => false }
      OptionParser.new do |opts|
        opts.banner = 'Usage: reagan [options]'
        opts.on('-o', '--override cb1,cb2', 'Comma separated list of cookbooks to test') do |cookbooks|
          flags[:override_cookbooks] = cookbooks.split(',')
        end
	
        opts.on('-p', '--print', 'Print the config options that will be used') do |config|
          flags[:print_config] = config
        end

        opts.on('-p', '--pull_num 123', 'Github pull number to test') do |pull|
          flags[:pull] = pull
        end

        opts.on('-c', '--config reagan.yml', 'Path to config file (defaults to /etc/reagan.yml)') do |config|
          flags[:config] = config
        end

        opts.on('-h', '--help', 'Displays Help') do
          puts opts
          exit
        end
      end.parse!

      flags
    end

    # loads the reagan.yml config file from /etc/reagan.yml or the passed location
    def load_config_file
      config = YAML.load_file(@flags[:config])
      if config == false
        puts "ERROR: Reagan config at #{@flags[:config]} does not contain any configuration data"
        exit 1
      end
      config
    rescue Errno::ENOENT
      puts "ERROR: Cannot load Reagan config file at #{@flags[:config]}"
      exit 1
    rescue Psych::SyntaxError
      puts "ERROR: Syntax error in Reagan config file at #{@flags[:config]}"
      exit 1
    end

    # join the config file with the passed flags into a single object
    def build_config
      config = @config_file
      config['flags'] = {}
      @flags.each { |k, v| config['flags'][k.to_s] = v }
      config
    end

    # pretty print the config hash
    def print_config(hash = nil, spaces = 0)
      hash = @settings if hash.nil?
      hash.each do |k, v|
        spaces.times { print ' ' }
        print k.to_s + ': '
        if v.class == Hash
          print "\n"
          print_config(v, spaces + 2)
        else
          puts v
        end
      end
    end
  end
end
