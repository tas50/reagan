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

# extend class with a marquee print function
class String
  def marquee
    puts "\n#{self}"
    length.times { printf '-' }
    puts "\n"
  end
end

module Reagan
  # the main class for the reagan app.  gets called by the reagan bin
  class Application
    require 'config'
    require 'change'
    require 'test_json'
    require 'test_knife'
    require 'test_reagan'
    require 'test_version'

    def initialize
      @config_obj = Reagan::Config.new
      @@config = @config_obj.settings
      @changes = Reagan::Change.new.files
    end

    def self.config
      @@config
    end

    # exit with a friendly message if nothing we test has been changed
    def check_empty_update
      objects_updated = false
      %w(cookbooks roles environments data_bags).each do |object|
        objects_updated = true unless @changes[object].empty?
      end

      unless objects_updated
        'No objects to test. Exiting'.marquee
        exit 0
      end
    end

    # check and see if the -p flag was passed and if so print the config hash
    def check_print_config
      return unless @@config['flags']['print_config']
      'Current config file / CLI flag values'.marquee
      @config_obj.print_config
      exit 0
    end

    # run tests on each changed cookbook
    def run
      check_print_config
      check_empty_update

      # print objects that will be tested
      'The following chef objects will be tested'.marquee
      %w(cookbooks roles environments data_bags).each do |type|
        unless @changes[type].empty?
          puts "#{type}:"
          @changes[type].each { |obj| puts '  ' + obj }
        end
      end

      results = []
      @changes['cookbooks'].each do |cookbook|
        "Testing cookbook #{cookbook}".marquee
        results <<  Reagan::TestKnife.new(cookbook).test
        results << Reagan::TestVersion.new(cookbook).test
        results <<  Reagan::TestReagan.new(cookbook).test
      end

      %w(data_bags roles environments).each do |type|
        @changes[type].each do |file|
          "Testing #{type} file #{file}".marquee
          results <<  TestJSON.new(file).test
        end
      end

      # print success or failure
      failure = results.include?(false)
      text = failure ? 'Reagan testing has failed' : 'All Reagan tests have suceeded'
      text.marquee

      # if any test failed then exit 1 so jenkins can pick up the failure
      exit 1 if failure
    end
  end
end
