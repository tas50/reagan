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
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

# builds a single config from passed flags, yaml config, and knife.rb
class ReaganConfig
  attr_accessor :settings
  def initialize(flags)
    @flags = flags
    @config_file = load_config_file
    @settings = build_config
  end

  # loads the reagan.yml config file from /etc/reagan.yml or the passed location
  def load_config_file
    begin
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
  end

  # join the config file with the passed flags into a single object
  def build_config
    config = @config_file
    config['flags'] = {}
    @flags.each{|k,v| config['flags'][k.to_s]=v}
    config
  end

end
