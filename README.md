reagan
======

Trust But Verify - Ruby Jenkins build script that automates the testing of Chef cookbooks

##Requirements
* Jenkins Github Pull Request Builder plugin
* A working knife toolchain
* Gems
  * octokit
  * chef
  * reidley

## Running Locally
While this app is written to be run as a Jenkins job it can also be run locally. This is particularly useful when you want to run the tests prior to commit.  To run Reagan locally use the following command line options:

* -c /path/to/reagan.yml
* -o overide,list,of,comma,separated,cookbooks
* -p 123 pull request number to manually test

##Running in Jenkins
coming soon!
