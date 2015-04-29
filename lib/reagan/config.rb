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
  require 'yaml'
  require 'optparse'
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

module Reagan
  # builds a single config from passed flags, yaml config, and knife.rb
  class Config
    # lazy load config settings
    def self::settings
      @settings ||= merge_config
    end

    # pretty print the config hash
    def self::print(hash = nil, spaces = 0)
      hash = @settings if hash.nil?
      hash.each do |k, v|
        spaces.times { print ' ' }
        print k.to_s + ': '
        if v.class == Hash
          print "\n"
          print(v, spaces + 2)
        else
          puts v
        end
      end
    end

    # grabs the flags passed in via command line
    def self::cli_flags
      if @cli_flags
        @cli_flags
      else
        flags = { 'config' => '/etc/reagan.yml' }
        OptionParser.new do |opts|
          opts.banner = 'Usage: reagan [options]'
          opts.on('-o', '--override cb1,cb2', Array, 'Comma separated list of cookbooks to test') do |cookbooks|
            flags[:override_cookbooks] = cookbooks
          end

          opts.on('-p', '--print', 'Print the config options that will be used') do |config|
            flags['print_config'] = config
          end

          opts.on('-p', '--pull_num 123', Integer, 'Github pull number to test') do |pull|
            flags['pull'] = pull
          end

          opts.on('-c', '--config reagan.yml', 'Path to config file (defaults to /etc/reagan.yml)') do |config|
            flags['config'] = config
          end

          opts.on('-h', '--help', 'Displays Help') do
            puts opts
            exit
          end
        end.parse!

        @cli_flags = flags
        flags
      end
    end

    # loads the reagan.yml config file from /etc/reagan.yml or the passed location
    def self::config_file
      config = YAML.load_file(cli_flags['config'])
      validate_config(config)

      config
      rescue Errno::ENOENT
        puts "ERROR: Cannot load Reagan config file at #{cli_flags['config']}".to_red
        exit 1
      rescue Psych::SyntaxError
        puts "ERROR: Syntax error in Reagan config file at #{cli_flags['config']}".to_red
        exit 1
    end

    # make sure the config was properly loaded and contains the various keys we need
    def self::validate_config(loaded_file)
      if loaded_file == false
        puts "ERROR: Reagan config at #{cli_flags['config']} does not contain any configuration data".to_red
        exit 1
      end

      # if workstation not defined in the config file try to use the Jenkins workspace variable
      unless loaded_file['jenkins'] && loaded_file['jenkins']['workspace_dir']
        workspace = ENV['WORKSPACE']
        if workspace
          loaded_file['jenkins'] = {}
          loaded_file['jenkins']['workspace_dir'] = workspace
        else
          puts 'Jenkins workspace_dir not defined in the config file and $WORKSPACE env variable empty. Exiting'.to_red
          exit
        end
      end
    end

    # join the config file with the passed flags into a single object
    def self::merge_config
      config = config_file
      config['flags'] = {}
      config['flags'].merge!(cli_flags)
      puts config
      config
    end
  end
end
