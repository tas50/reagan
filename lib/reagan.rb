#!/usr/bin/env ruby
#

# load the libs
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

begin
  require 'change'
  require 'test_knife'
  require 'test_version'
rescue LoadError => e
  raise "Missing lib #{e}"
end

# the main class for the reagan app.  gets called by the reagan bin
class Reagan

  # nicely prints marques
  def pretty_print(string)
    puts "\n#{string}"
    string.length.times { printf '-' }
    puts "\n"
  end

  # grab the changes and run the tests
  def run
    # grab all cookbooks changed
    cookbooks = ReaganChange.new.files

    pretty_print('The following cookbooks were changed')
    cookbooks.each { |cb| puts cb }

    results = []
    cookbooks.each do |cookbook|
      pretty_print("Testing cookbook #{cookbook}")
      results << ReaganTestVersion.new(cookbook).test
      results <<  ReaganTestKnife.new(cookbook).test
    end

    # if any test failed then exit 1 so jenkins can pick up the failure
    exit 1 if results.include?(false)
  end
end
