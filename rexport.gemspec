require File.expand_path('../lib/rexport/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'rexport'
  s.version = Rexport::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Aaron Baldwin', 'Jonathan Garvin', 'WWIDEA, Inc']

  s.description = <<-EOS
    Ruby on Rails gem to manage exports.
  EOS
  s.summary = %q{Ruby on Rails gem to manage exports.}
  s.homepage = %q{https://github.com/wwidea/rexport}

  s.add_dependency('rails','~> 3.0.0')

  s.add_development_dependency('rake','>= 0.9.2')
  s.add_development_dependency('rdoc','>= 3.12')
  s.add_development_dependency('factory_girl','~> 2.5.0')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('mocha')

  s.files = `git ls-files`.split("\n")

  s.require_paths = ["lib"]
end