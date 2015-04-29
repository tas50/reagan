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

module Reagan
  # tests cookbooks using knife cookbook test functionality
  class TestKnife
    def initialize(cookbook)
      @cookbook = cookbook
    end

    # performs knife cookbook test
    # returns  true if  cookbook passed or false if it failed
    def test
      # grab the version of the cookbook in the local metadata
      result = system "knife cookbook test -o #{File.join(Config.settings['jenkins']['workspace_dir'], 'cookbooks')} #{@cookbook} > /dev/null 2>&1"

      puts 'Running knife cookbook test:'
      puts result ? 'PASS: Knife cookbook test was successful'.indent : 'FAIL: Knife cookbookk test was NOT successful'.indent
      result
    end
  end
end
