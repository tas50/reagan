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

# tests cookbooks using the reagan-test rake tasks
class TestReagan < Reagan
  def initialize(cookbook)
    @cookbook = cookbook
  end

  # performs knife cookbook test
  # returns  true if  cookbook passed or false if it failed
  def test
    puts 'Running reagan_test Rake task:'
    # run the rake task if it exists, otherwise skip
    if File.exist?(File.join(@@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook, 'Rakefile'))
      result = system "rake #{File.join(@@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook, 'Rakefile')} > /dev/null 2>&1"
      puts result ? '    PASS: reagan_test Rake task was successful' : '    FAIL: reagan_test Rake task was NOT successful'
      result
    else
      puts '    SKIP: No Rakefile found in the cookbook path. Skipping test'
    end
    true
  end
end
