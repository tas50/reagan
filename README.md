reagan
======

Trust But Verify - Ruby Jenkins build script that automates the testing of individual Chef cookbooks in a monolithic chef-repo.  Reagan allows you to test only the cookbooks that have changed in a particular pull request and includes the following tests:

* Ensure versions are bumped in cookbooks vs. the  current version on the server
* Validate ruby / templates according to knife cookbook test
* Optionally test anything present in a per cookbook rake task called reagan_test (rubocop? foodcritic? chefspec?)

##Requirements
* Ruby 1.9.3 (rbenv Jenkins plugin suggested to get more modern Ruby)
* Jenkins Github Pull Request Builder plugin
* A working knife toolchain on your Jenkins boxes
* Gems
  * octokit
  * chef
  * ridley

## Running Locally
While this app is written to be run as a Jenkins job it can also be run locally. This is particularly useful when you want to run the tests prior to commit.  To run Reagan locally use the following command line options:

* -c /path/to/reagan.yml
* -o overide,list,of,comma,separated,cookbooks
* -p 123 pull request number to manually test a github pull request

##Running in Jenkins
1) Create a Gemfile in your chef-repo and add the reagan gem to the file.  Example:

```ruby
source 'https://rubygems.org'

gem 'chef', '~> 11.0'
gem 'berkshelf', '~> 3.1'

group :test do
  gem 'reagan', '~> 0.4'
  gem 'rubocop', '~> 0.26'
  gem 'foodcritic', '~> 4.0'
end
```

2) Setup a Jenkins job per the instructions in the Github Pull Request Plugin documentation at https://wiki.jenkins-ci.org/display/JENKINS/GitHub+pull+request+builder+plugin

3) Add the following it:ms to your job configuration:

 * If you're using the rbenv plugin enable the plugin under 'Build Environment', set a ruby version, and add 'bundler' to the  list of gems to preinstall
 * Under Build -> Execute shell add the following command: bundle install; bundle exec reagan
 * Under Build Triggers -> Advanced either set the crontab to */2 * * * * or setup building using github web hooks (not possible if your jenkins is not exposed to the Web)

3) If you don't already have a Jenkins user for your Github account create one now.  You can always use your own account's privs, but you really shouldn't do this.  Once you have an account with privs on your chef-repo go to https://github.com/settings/applications and create a oauth token.  Make sure the token has repo and public_repo scope.  Same off the token for the config creation below

4) Create a Reagan config file (example is in the repo at reagan.yml.EXAMPLE).  Unless you specify a custom config location with -c this should be at /etc/reagan.yml, and should be owned by the Jenkins user with 600 privs so to keep your github token private.  The config contains the following items:

 * Github auth_token: that you created in the Github UI
 * Github repo: the Org/repo format name of your chef repo
 * Jenkins workspace_dir: The path to the checked out chef-repo workspace used by Jenkins
 * Chef pem_path: Path to a chef .pem file on your jenkins host
 * Chef client_name: The name of the client for the jenkins chef install on your Jenkins host (not the server's client name)
 * Chef server_url: The full URL of your Chef server

5) At this point you should be able to open a test pull request with



