require 'date'

Gem::Specification.new do |s|
  s.name        = 'reagan'
  s.version     = '1.1.0'
  s.date        = Date.today.to_s
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary     = 'Trust But Verify - Ruby build script for Jenkins that automates the testing of Chef cookbooks'
  s.description = s.summary
  s.authors     = ['Tim Smith']
  s.email       = 'tsmith@chef.io'
  s.homepage    = 'http://www.github.com/tas50/reagan'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 2.2'
  s.add_dependency 'chef', '>= 12.0'
  s.add_dependency 'octokit', '~> 3.0'
  s.add_dependency 'ridley', '~> 4.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rubocop', '~> 0.51.0'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'reagan', '--main', 'README.md']
end
