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

# add a simple method for making marquees
class String
  def marquee
    puts "\n#{self}"
    length.times { printf '-' }
    puts "\n"
  end

  def to_red
    "\033[31m#{self}\033[0m"
  end

  def indent(double_space_count = 1)
    double_space_count.times { insert(0, '  ') }
    self
  end
end
