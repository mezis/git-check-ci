# -*- encoding: utf-8 -*-
require File.expand_path('../lib/git-check-ci/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "git-check-ci"
  s.version       = GitCheckCI::VERSION
  s.platform      = Gem::Platform::RUBY

  s.authors       = ["Julien Letessier"]
  s.email         = ["julien.letessier@gmail.com"]
  s.description   = %q{Check CI status of the local project}
  s.summary       = %q{
    Provides git-check-ci, which can display textual or graphic status
    feedback based on a CI server's results.
  }
  s.homepage      = "http://github.com/mezis/git-check-ci"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "ruby-prof"

  s.add_dependency "httparty"
  s.add_dependency "daemons", '~> 1.1'
  s.add_dependency "json"
  s.add_dependency "thor"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^spec})
  s.require_paths = ["lib"]
end
