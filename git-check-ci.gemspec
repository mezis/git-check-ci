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

  # s.add_development_dependency "bundler", ">= 1.0.0"
  # s.add_development_dependency "rspec", "~> 2.4.0"
  # s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  # s.add_development_dependency "http_logger"
  # s.add_development_dependency "webmock"
  # s.add_development_dependency "guard-rspec"
  # s.add_development_dependency "ruby_gntp"

  # s.add_dependency "rails", "~> 2.3.12"
  s.add_dependency "httparty"
  # s.add_dependency "json"
  # s.add_dependency "configatron"
  # s.add_dependency "whatlanguage"
  # s.add_dependency "nokogiri"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^spec})
  s.require_paths = ["lib"]
end
