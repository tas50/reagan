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

require 'json'

module Reagan
  # tests to make sure the version has been updated on the cookbook
  class TestJSON
    def initialize(file)
      @file = file
    end

    # performs JSON format test
    # returns  true if json can be parsed and false if it cannot
    def test
      puts 'Running JSON parsing test:'
      begin
        json_file = File.read(File.join(Config.settings['jenkins']['workspace_dir'], @file))
        JSON.parse(json_file)
        success = true
      rescue JSON::JSONError
        success = false
      end
      puts success ? 'PASS: JSON parses'.indent : 'FAIL: JSON does NOT parse'.indent
      success
    end
  end
end
