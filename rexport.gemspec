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

  s.files = `git ls-files`.split("\n")

  s.require_paths = ["lib"]
end