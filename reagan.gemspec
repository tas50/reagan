Gem::Specification.new do |s|
  s.name        = 'reagan'
  s.version     = '0.2.0'
  s.date        = Date.today.to_s
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary     = 'Trust But Verify - Ruby build script for Jenkins that automates the testing of Chef cookbooks'
  s.description = s.summary
  s.authors     = ['Tim Smith']
  s.email       = 'tim@cozy.co'
  s.add_dependency 'octokit', '~> 3.0'
  s.add_dependency 'chef', '~> 11.0'
  s.add_dependency 'ridley', '~> 4.0'
  s.add_development_dependency 'rake', '~> 10.0'
  s.files       = %w(Rakefile README.md LICENSE bin/reagan reagan.yml.EXAMPLE) + Dir.glob('lib/*')
  s.homepage    =
    'http://www.github.com/tas50/reagan'
  s.license = 'Apache-2.0'
  s.executables << 'reagan'
end
