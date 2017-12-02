
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

# main Reagan application to which gathers configs, determines changes, and runs tests
module Reagan
  require 'core/ext/string'
  require 'reagan/config'
  require 'reagan/changeset'
  require 'reagan/test_json'
  require 'reagan/test_knife'
  require 'reagan/test_reagan'
  require 'reagan/test_version'

  # exit with a friendly message if nothing we test has been changed
  def self::check_empty_update
    if ChangeSet.empty?
      'No objects to test. Exiting'.marquee
      exit 0
    end
  end

  # check and see if the -p flag was passed and if so print the config hash
  def self::check_print_config
    return unless Config.settings['flags']['print_config']
    'Current config file / CLI flag values'.marquee
    Config.pretty_print
    exit 0
  end

  # run tests on each changed cookbook
  def self::run
    # ensure output syncs to the console so jenkins can record it
    $stdout.sync = $stderr.sync = true

    Config.validate
    check_print_config
    check_empty_update

    # print objects that will be tested
    'The following chef objects will be tested'.marquee
    %w[cookbooks roles environments data_bags].each do |type|
      unless ChangeSet.files[type].empty?
        puts "#{type}:"
        ChangeSet.files[type].each { |obj| puts '  ' + obj }
      end
    end

    results = []
    ChangeSet.files['cookbooks'].each do |cookbook|
      "Testing cookbook #{cookbook}".marquee
      results << Reagan::TestKnife.new(cookbook).test
      results << Reagan::TestVersion.new(cookbook).test
      results << Reagan::TestReagan.new(cookbook).test
    end

    %w[data_bags roles environments].each do |type|
      ChangeSet.files[type].each do |file|
        "Testing #{type} file #{file}".marquee
        results << TestJSON.new(file).test
      end
    end

    # print success or failure
    failure = results.include?(false)
    text = failure ? 'Reagan testing has failed'.to_red : 'All Reagan tests have suceeded'.to_green
    text.marquee

    # if any test failed then exit 1 so jenkins can pick up the failure
    exit 1 if failure
  end
end
