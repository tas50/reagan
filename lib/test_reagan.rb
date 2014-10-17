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

# tests cookbooks using tests defined in reagan_test.yml files
class TestReagan < Reagan
  def initialize(cookbook)
    @cookbook = cookbook
  end

  # returns  true if tests defined in reagan_test.yml passed/don't exist or false if it failed
  def test
    puts 'Running reagan_test.yml defined tests:'
    # check to see if a reagan_test.yml file exists
    if File.exist?(File.join(@@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook, 'reagan_test.yml'))

      # load the reagan config file
      reagan_def = YAML.load_file(File.join(@@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook, 'reagan_test.yml'))

      # change into the cookbook dir so rake tests run locally
      Dir.chdir(File.join(@@config['jenkins']['workspace_dir'], 'cookbooks', @cookbook))

      status = true
      reagan_def['tests'].each do |test|
        puts "  reagan_test.yml test: '#{test}'"
        result = system test
        status = false if result == false
      end
      puts status ? '    PASS: reagan_test.yml test was successful' : '    FAIL: reagan_test.yml test was NOT successful'
      status
    else
      puts '    SKIP: No reagan_test.yml file found in the cookbook path. Skipping test'
      status
    end
  end
end
