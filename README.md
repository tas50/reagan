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
coming soon!
