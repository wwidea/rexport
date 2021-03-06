$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rexport/version"

Gem::Specification.new do |s|
  s.name = 'rexport'
  s.version = Rexport::VERSION
  s.authors = ['Aaron Baldwin', 'Brightways Learning']
  s.email = ["developers@brightwayslearning.org"]
  s.homepage = 'https://github.com/wwidea/rexport'
  s.summary = 'Ruby on Rails gem to manage exports.'
  s.description = 'Rexport integrates into a Rails application making model data available for export into CSV files.'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails',   '>= 6.0.3'

  s.add_development_dependency 'factory_bot',   '~> 6.2'
  s.add_development_dependency 'sqlite3',       '~> 1.4'
  s.add_development_dependency 'mocha',         '~> 1.13'
end
