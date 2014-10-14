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

# the main class for the reagan app.  gets called by the reagan bin
class Reagan
  require 'yaml'
  require 'change'
  require 'test_knife'
  require 'test_version'
  require 'test_reagan'

  attr_accessor :config
  def initialize(options)
    @@config = YAML.load_file(options[:config])
    @options = options
  end

  # nicely prints marques
  def pretty_print(string)
    puts "\n#{string}"
    string.length.times { printf '-' }
    puts "\n"
  end

  # grab the changes and run the tests
  def run
    # use passed in list of cookbooks or grab from GH
    if @options[:cookbooks]
      cookbooks = @options[:cookbooks].split(',')
    else
      cookbooks = Change.new(@options).files
    end

    pretty_print('The following cookbooks will be tested')
    cookbooks.each { |cb| puts cb }

    results = []
    cookbooks.each do |cookbook|
      pretty_print("Testing cookbook #{cookbook}")
      results <<  TestKnife.new(cookbook).test
      results << TestVersion.new(cookbook).test
      results <<  TestReagan.new(cookbook).test
    end

    # if any test failed then exit 1 so jenkins can pick up the failure
    exit 1 if results.include?(false)
  end
end
